// ScoreControllerTests.cs
// Score 시스템 테스트 - TDD 방식으로 작성

using NUnit.Framework;
using Systems.Score;

namespace Tests.Score
{
    [TestFixture]
    public class ScoreControllerTests
    {
        private ScoreController _controller;
        private LinearComboStrategy _comboStrategy;

        [SetUp]
        public void SetUp()
        {
            _comboStrategy = new LinearComboStrategy();
            _controller = new ScoreController(_comboStrategy);
        }

        #region AddScore Tests

        [Test]
        public void AddScore_SinglePoint_IncreasesScore()
        {
            // Arrange
            const int points = 100;

            // Act
            int addedScore = _controller.AddScore(points);

            // Assert
            Assert.AreEqual(points, _controller.CurrentScore);
            Assert.AreEqual(points, addedScore);
        }

        [Test]
        public void AddScore_MultiplePoints_AccumulatesScore()
        {
            // Arrange & Act
            _controller.AddScore(100);
            _controller.AddScore(50);

            // Assert
            Assert.AreEqual(150, _controller.CurrentScore);
        }

        [Test]
        public void AddScore_WithCombo_AppliesMultiplier()
        {
            // Arrange
            _controller.IncrementCombo(); // combo = 1, multiplier = 1.1
            const int basePoints = 100;

            // Act
            int addedScore = _controller.AddScore(basePoints);

            // Assert
            // LinearComboStrategy: multiplier = 1.0 + (combo * 0.1) = 1.1
            int expectedScore = (int)(basePoints * 1.1f);
            Assert.AreEqual(expectedScore, addedScore);
            Assert.AreEqual(expectedScore, _controller.CurrentScore);
        }

        [Test]
        public void AddScore_ZeroPoints_NoChange()
        {
            // Arrange
            _controller.AddScore(100);

            // Act
            int addedScore = _controller.AddScore(0);

            // Assert
            Assert.AreEqual(0, addedScore);
            Assert.AreEqual(100, _controller.CurrentScore);
        }

        [Test]
        public void AddScore_NegativePoints_TreatedAsZero()
        {
            // Arrange
            _controller.AddScore(100);

            // Act
            int addedScore = _controller.AddScore(-50);

            // Assert
            Assert.AreEqual(0, addedScore);
            Assert.AreEqual(100, _controller.CurrentScore);
        }

        #endregion

        #region SubtractScore Tests

        [Test]
        public void SubtractScore_ReducesScore()
        {
            // Arrange
            _controller.AddScore(100);

            // Act
            int subtracted = _controller.SubtractScore(30);

            // Assert
            Assert.AreEqual(30, subtracted);
            Assert.AreEqual(70, _controller.CurrentScore);
        }

        [Test]
        public void SubtractScore_MoreThanCurrent_ScoreBecomesZero()
        {
            // Arrange
            _controller.AddScore(50);

            // Act
            int subtracted = _controller.SubtractScore(100);

            // Assert
            Assert.AreEqual(50, subtracted); // 실제 감소된 양
            Assert.AreEqual(0, _controller.CurrentScore);
        }

        [Test]
        public void SubtractScore_NegativeValue_NoChange()
        {
            // Arrange
            _controller.AddScore(100);

            // Act
            int subtracted = _controller.SubtractScore(-50);

            // Assert
            Assert.AreEqual(0, subtracted);
            Assert.AreEqual(100, _controller.CurrentScore);
        }

        [Test]
        public void SubtractScore_DoesNotAffectCombo()
        {
            // Arrange
            _controller.IncrementCombo();
            _controller.IncrementCombo();
            _controller.AddScore(100);
            int comboBeforeSubtract = _controller.ComboCount;

            // Act
            _controller.SubtractScore(30);

            // Assert
            Assert.AreEqual(comboBeforeSubtract, _controller.ComboCount);
        }

        #endregion

        #region Combo Tests

        [Test]
        public void IncrementCombo_IncreasesComboCount()
        {
            // Act
            _controller.IncrementCombo();

            // Assert
            Assert.AreEqual(1, _controller.ComboCount);
        }

        [Test]
        public void IncrementCombo_Multiple_AccumulatesCombo()
        {
            // Act
            _controller.IncrementCombo();
            _controller.IncrementCombo();
            _controller.IncrementCombo();

            // Assert
            Assert.AreEqual(3, _controller.ComboCount);
        }

        [Test]
        public void ResetCombo_ResetsComboToZero()
        {
            // Arrange
            _controller.IncrementCombo();
            _controller.IncrementCombo();

            // Act
            _controller.ResetCombo();

            // Assert
            Assert.AreEqual(0, _controller.ComboCount);
        }

        [Test]
        public void ComboMultiplier_ReflectsCurrentCombo()
        {
            // Arrange & Act
            _controller.IncrementCombo(); // combo = 1

            // Assert
            // LinearComboStrategy: 1.0 + (1 * 0.1) = 1.1
            Assert.AreEqual(1.1f, _controller.ComboMultiplier, 0.001f);
        }

        #endregion

        #region Reset Tests

        [Test]
        public void Reset_ClearsScoreAndCombo()
        {
            // Arrange
            _controller.AddScore(500);
            _controller.IncrementCombo();
            _controller.IncrementCombo();

            // Act
            _controller.Reset();

            // Assert
            Assert.AreEqual(0, _controller.CurrentScore);
            Assert.AreEqual(0, _controller.ComboCount);
            Assert.AreEqual(1.0f, _controller.ComboMultiplier, 0.001f);
        }

        #endregion

        #region Modifier Tests

        [Test]
        public void RegisterModifier_AffectsScore()
        {
            // Arrange
            var modifier = new TestScoreModifier("test", bonusPoints: 10, multiplier: 1.0f);
            _controller.RegisterModifier(modifier);

            // Act
            int addedScore = _controller.AddScore(100);

            // Assert
            // base 100 + modifier bonus 10 = 110
            Assert.AreEqual(110, addedScore);
        }

        [Test]
        public void RegisterModifier_MultiplierAffectsScore()
        {
            // Arrange
            var modifier = new TestScoreModifier("doubler", bonusPoints: 0, multiplier: 2.0f);
            _controller.RegisterModifier(modifier);

            // Act
            int addedScore = _controller.AddScore(100);

            // Assert
            // base 100 * multiplier 2.0 = 200
            Assert.AreEqual(200, addedScore);
        }

        [Test]
        public void UnregisterModifier_StopsAffectingScore()
        {
            // Arrange
            var modifier = new TestScoreModifier("test", bonusPoints: 50, multiplier: 1.0f);
            _controller.RegisterModifier(modifier);
            _controller.AddScore(100); // 150

            // Act
            _controller.UnregisterModifier(modifier);
            int addedScore = _controller.AddScore(100);

            // Assert
            Assert.AreEqual(100, addedScore); // 모디파이어 없이 순수 100
            Assert.AreEqual(250, _controller.CurrentScore); // 150 + 100
        }

        [Test]
        public void MultipleModifiers_ApplyInPriorityOrder()
        {
            // Arrange
            var addModifier = new TestScoreModifier("add", priority: 1, bonusPoints: 50, multiplier: 1.0f);
            var multiplyModifier = new TestScoreModifier("multiply", priority: 2, bonusPoints: 0, multiplier: 2.0f);
            _controller.RegisterModifier(multiplyModifier);
            _controller.RegisterModifier(addModifier);

            // Act
            int addedScore = _controller.AddScore(100);

            // Assert
            // Priority order: add first (priority 1), then multiply (priority 2)
            // (100 + 50) * 2.0 = 300
            Assert.AreEqual(300, addedScore);
        }

        [Test]
        public void InactiveModifier_DoesNotAffectScore()
        {
            // Arrange
            var modifier = new TestScoreModifier("inactive", bonusPoints: 100, multiplier: 1.0f, isActive: false);
            _controller.RegisterModifier(modifier);

            // Act
            int addedScore = _controller.AddScore(100);

            // Assert
            Assert.AreEqual(100, addedScore); // 비활성 모디파이어는 적용 안 됨
        }

        #endregion

        #region Event Tests

        [Test]
        public void AddScore_FiresScoreChangedEvent()
        {
            // Arrange
            ScoreChangedEventArgs receivedArgs = null;
            _controller.OnScoreChanged += args => receivedArgs = args;

            // Act
            _controller.AddScore(100);

            // Assert
            Assert.IsNotNull(receivedArgs);
            Assert.AreEqual(0, receivedArgs.PreviousScore);
            Assert.AreEqual(100, receivedArgs.CurrentScore);
            Assert.AreEqual(100, receivedArgs.Delta);
            Assert.AreEqual(ScoreChangeType.Add, receivedArgs.ChangeType);
        }

        [Test]
        public void SubtractScore_FiresScoreChangedEvent()
        {
            // Arrange
            _controller.AddScore(100);
            ScoreChangedEventArgs receivedArgs = null;
            _controller.OnScoreChanged += args => receivedArgs = args;

            // Act
            _controller.SubtractScore(30);

            // Assert
            Assert.IsNotNull(receivedArgs);
            Assert.AreEqual(100, receivedArgs.PreviousScore);
            Assert.AreEqual(70, receivedArgs.CurrentScore);
            Assert.AreEqual(-30, receivedArgs.Delta);
            Assert.AreEqual(ScoreChangeType.Subtract, receivedArgs.ChangeType);
        }

        [Test]
        public void IncrementCombo_FiresComboChangedEvent()
        {
            // Arrange
            ComboChangedEventArgs receivedArgs = null;
            _controller.OnComboChanged += args => receivedArgs = args;

            // Act
            _controller.IncrementCombo();

            // Assert
            Assert.IsNotNull(receivedArgs);
            Assert.AreEqual(0, receivedArgs.PreviousCombo);
            Assert.AreEqual(1, receivedArgs.CurrentCombo);
            Assert.IsFalse(receivedArgs.WasReset);
        }

        [Test]
        public void ResetCombo_FiresComboChangedEventWithResetFlag()
        {
            // Arrange
            _controller.IncrementCombo();
            _controller.IncrementCombo();
            ComboChangedEventArgs receivedArgs = null;
            _controller.OnComboChanged += args => receivedArgs = args;

            // Act
            _controller.ResetCombo();

            // Assert
            Assert.IsNotNull(receivedArgs);
            Assert.AreEqual(2, receivedArgs.PreviousCombo);
            Assert.AreEqual(0, receivedArgs.CurrentCombo);
            Assert.IsTrue(receivedArgs.WasReset);
        }

        #endregion
    }

    #region Test Helpers

    /// <summary>
    /// 테스트용 ScoreModifier 구현
    /// </summary>
    public class TestScoreModifier : IScoreModifier
    {
        public string Id { get; }
        public int Priority { get; }
        public bool IsActive { get; }

        private readonly int _bonusPoints;
        private readonly float _multiplier;

        public TestScoreModifier(
            string id,
            int priority = 0,
            int bonusPoints = 0,
            float multiplier = 1.0f,
            bool isActive = true)
        {
            Id = id;
            Priority = priority;
            IsActive = isActive;
            _bonusPoints = bonusPoints;
            _multiplier = multiplier;
        }

        public int ModifyScore(ScoreContext context)
        {
            return _bonusPoints;
        }

        public float ModifyMultiplier(ScoreContext context)
        {
            return _multiplier;
        }
    }

    #endregion
}
