# Async Code Testing

## UniTask 소개

Unity 코루틴은 테스트하기 어렵습니다. UniTask는 Unity에 최적화된 async/await 패턴으로 테스트 가능한 비동기 코드를 작성할 수 있게 해줍니다.

### 설치
```json
// Packages/manifest.json
{
  "dependencies": {
    "com.cysharp.unitask": "2.5.4"
  }
}
```

---

## Coroutine vs UniTask

### ❌ Coroutine - 테스트 어려움
```csharp
public class DataLoader : MonoBehaviour
{
    public bool IsLoaded { get; private set; }
    public GameData Data { get; private set; }

    public IEnumerator LoadDataCoroutine(string path)
    {
        IsLoaded = false;
        var request = Resources.LoadAsync<TextAsset>(path);
        yield return request;

        if (request.asset != null)
        {
            var json = (request.asset as TextAsset).text;
            Data = JsonUtility.FromJson<GameData>(json);
            IsLoaded = true;
        }
    }
}

// 테스트 - Play Mode 필요, 복잡
[UnityTest]
public IEnumerator LoadData_ReturnsValidData()
{
    var go = new GameObject();
    var loader = go.AddComponent<DataLoader>();

    yield return loader.StartCoroutine(loader.LoadDataCoroutine("gamedata"));

    Assert.IsTrue(loader.IsLoaded);
    Assert.IsNotNull(loader.Data);

    Object.Destroy(go);
}
```

### ✅ UniTask - 테스트 용이
```csharp
using Cysharp.Threading.Tasks;

// 순수 C# 클래스로 분리
public class DataLoader
{
    private readonly IResourceLoader resourceLoader;

    public DataLoader(IResourceLoader resourceLoader)
    {
        this.resourceLoader = resourceLoader;
    }

    public async UniTask<GameData> LoadDataAsync(string path)
    {
        var json = await resourceLoader.LoadTextAsync(path);

        if (string.IsNullOrEmpty(json))
        {
            throw new DataLoadException($"Failed to load: {path}");
        }

        return JsonUtility.FromJson<GameData>(json);
    }
}

// 테스트 - Edit Mode 가능
[Test]
public async Task LoadData_WithValidPath_ReturnsData()
{
    var mockLoader = Substitute.For<IResourceLoader>();
    mockLoader.LoadTextAsync("test")
              .Returns(UniTask.FromResult("{\"level\": 1, \"score\": 100}"));

    var dataLoader = new DataLoader(mockLoader);

    var result = await dataLoader.LoadDataAsync("test");

    Assert.AreEqual(1, result.Level);
    Assert.AreEqual(100, result.Score);
}

[Test]
public void LoadData_WithInvalidPath_ThrowsException()
{
    var mockLoader = Substitute.For<IResourceLoader>();
    mockLoader.LoadTextAsync("invalid")
              .Returns(UniTask.FromResult<string>(null));

    var dataLoader = new DataLoader(mockLoader);

    Assert.ThrowsAsync<DataLoadException>(async () =>
        await dataLoader.LoadDataAsync("invalid"));
}
```

---

## UniTask 테스트 패턴

### 1. 기본 비동기 테스트
```csharp
using NUnit.Framework;
using Cysharp.Threading.Tasks;

[TestFixture]
public class AsyncServiceTests
{
    [Test]
    public async Task FetchData_ReturnsDataWithinTimeout()
    {
        var service = new NetworkService();

        var result = await service.FetchDataAsync("api/users")
                                  .Timeout(TimeSpan.FromSeconds(5));

        Assert.IsNotNull(result);
        Assert.Greater(result.Count, 0);
    }
}
```

### 2. 타임아웃 테스트
```csharp
[Test]
public async Task LongOperation_CancelsAfterTimeout()
{
    var service = new SlowService();
    var cts = new CancellationTokenSource(TimeSpan.FromMilliseconds(100));

    try
    {
        await service.SlowOperationAsync(cts.Token);
        Assert.Fail("Should have thrown OperationCanceledException");
    }
    catch (OperationCanceledException)
    {
        Assert.Pass();
    }
}
```

### 3. 순차 실행 테스트
```csharp
[Test]
public async Task ProcessStages_ExecutesInOrder()
{
    var processor = new StageProcessor();
    var executionOrder = new List<string>();

    processor.OnStageStarted += stage => executionOrder.Add(stage);

    await processor.ProcessAllStagesAsync();

    Assert.AreEqual(new[] { "Stage1", "Stage2", "Stage3" }, executionOrder);
}
```

### 4. 병렬 실행 테스트
```csharp
[Test]
public async Task LoadAllResources_LoadsInParallel()
{
    var loader = new ResourceLoader();
    var paths = new[] { "res1", "res2", "res3" };

    var stopwatch = System.Diagnostics.Stopwatch.StartNew();

    var results = await UniTask.WhenAll(
        paths.Select(p => loader.LoadAsync(p))
    );

    stopwatch.Stop();

    // 병렬이면 개별 로드 시간 합보다 짧아야 함
    Assert.Less(stopwatch.ElapsedMilliseconds, 300);
    Assert.AreEqual(3, results.Length);
}
```

---

## Play Mode 비동기 테스트

### UniTask + UnityTest
```csharp
using Cysharp.Threading.Tasks;
using UnityEngine.TestTools;

public class PlayModeAsyncTests
{
    [UnityTest]
    public IEnumerator SpawnEnemy_WaitsForAnimation() => UniTask.ToCoroutine(async () =>
    {
        var spawner = new GameObject().AddComponent<EnemySpawner>();

        var enemy = await spawner.SpawnWithAnimationAsync();

        Assert.IsNotNull(enemy);
        Assert.IsTrue(enemy.IsReady);
    });

    [UnityTest]
    public IEnumerator GameFlow_CompletesAllPhases() => UniTask.ToCoroutine(async () =>
    {
        var gameManager = Object.FindObjectOfType<GameManager>();
        var phases = new List<GamePhase>();

        gameManager.OnPhaseChanged += phase => phases.Add(phase);

        await gameManager.StartGameAsync();

        Assert.AreEqual(
            new[] { GamePhase.Init, GamePhase.Ready, GamePhase.Playing },
            phases
        );
    });
}
```

---

## 비동기 코드 설계 원칙

### 1. 취소 지원
```csharp
public class NetworkService
{
    public async UniTask<string> FetchAsync(
        string url,
        CancellationToken cancellationToken = default)
    {
        using var www = UnityWebRequest.Get(url);

        await www.SendWebRequest()
                 .WithCancellation(cancellationToken);

        cancellationToken.ThrowIfCancellationRequested();

        return www.downloadHandler.text;
    }
}

// 테스트
[Test]
public async Task Fetch_WhenCancelled_ThrowsOperationCanceled()
{
    var service = new NetworkService();
    var cts = new CancellationTokenSource();

    var task = service.FetchAsync("http://slow-api.com", cts.Token);
    cts.Cancel();

    Assert.ThrowsAsync<OperationCanceledException>(() => task.AsTask());
}
```

### 2. 진행률 보고
```csharp
public class ResourceLoader
{
    public async UniTask LoadAllAsync(
        string[] paths,
        IProgress<float> progress = null,
        CancellationToken ct = default)
    {
        for (int i = 0; i < paths.Length; i++)
        {
            await LoadOneAsync(paths[i], ct);
            progress?.Report((float)(i + 1) / paths.Length);
        }
    }
}

// 테스트
[Test]
public async Task LoadAll_ReportsProgress()
{
    var loader = new ResourceLoader();
    var progressValues = new List<float>();
    var progress = new Progress<float>(v => progressValues.Add(v));

    await loader.LoadAllAsync(
        new[] { "a", "b", "c", "d" },
        progress
    );

    Assert.AreEqual(
        new[] { 0.25f, 0.5f, 0.75f, 1.0f },
        progressValues
    );
}
```

---

## 권장 패턴

```csharp
// ✅ 테스트 가능한 비동기 서비스 구조
public interface IAsyncOperation<T>
{
    UniTask<T> ExecuteAsync(CancellationToken ct = default);
}

public class LoadGameOperation : IAsyncOperation<GameState>
{
    private readonly ISaveSystem saveSystem;
    private readonly IResourceLoader resourceLoader;

    public LoadGameOperation(ISaveSystem save, IResourceLoader resources)
    {
        this.saveSystem = save;
        this.resourceLoader = resources;
    }

    public async UniTask<GameState> ExecuteAsync(CancellationToken ct = default)
    {
        // 병렬 로드
        var (saveData, config) = await UniTask.WhenAll(
            saveSystem.LoadAsync(ct),
            resourceLoader.LoadConfigAsync(ct)
        );

        return new GameState(saveData, config);
    }
}

// 테스트
[Test]
public async Task LoadGame_LoadsSaveAndConfig()
{
    var mockSave = Substitute.For<ISaveSystem>();
    var mockResources = Substitute.For<IResourceLoader>();

    mockSave.LoadAsync(default).ReturnsForAnyArgs(
        UniTask.FromResult(new SaveData { Level = 5 })
    );
    mockResources.LoadConfigAsync(default).ReturnsForAnyArgs(
        UniTask.FromResult(new GameConfig())
    );

    var operation = new LoadGameOperation(mockSave, mockResources);
    var state = await operation.ExecuteAsync();

    Assert.AreEqual(5, state.SaveData.Level);
    Assert.IsNotNull(state.Config);
}
```
