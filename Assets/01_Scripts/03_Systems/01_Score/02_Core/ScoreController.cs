// ScoreController.cs
// Score 시스템의 핵심 로직 (Pure C# - TDD 대상)

using System;
using System.Collections.Generic;
using System.Linq;

namespace Systems.Score
{
    /// <summary>
    /// Score 시스템의 핵심 컨트롤러
    /// 점수 관리, 콤보 시스템, 모디파이어를 통합 관리합니다.
    ///
    /// 확장 포인트:
    /// - IComboStrategy: 콤보 배율 계산 전략
    /// - IScoreModifier: 점수 보너스/페널티
    /// </summary>
    public class ScoreController : IScoreSystem
    {
        private int _currentScore;
        private int _comboCount;
        private readonly IComboStrategy _comboStrategy;
        private readonly List<IScoreModifier> _modifiers;

        /// <summary>
        /// 현재 점수
        /// </summary>
        public int CurrentScore => _currentScore;

        /// <summary>
        /// 현재 콤보 카운트
        /// </summary>
        public int ComboCount => _comboCount;

        /// <summary>
        /// 현재 적용 중인 콤보 배율
        /// </summary>
        public float ComboMultiplier => _comboStrategy.CalculateMultiplier(_comboCount);

        /// <summary>
        /// 점수 변경 이벤트
        /// </summary>
        public event Action<ScoreChangedEventArgs> OnScoreChanged;

        /// <summary>
        /// 콤보 변경 이벤트
        /// </summary>
        public event Action<ComboChangedEventArgs> OnComboChanged;

        /// <summary>
        /// ScoreController 생성자
        /// </summary>
        /// <param name="comboStrategy">콤보 배율 계산 전략 (null이면 기본 LinearComboStrategy 사용)</param>
        public ScoreController(IComboStrategy comboStrategy = null)
        {
            _comboStrategy = comboStrategy ?? new LinearComboStrategy();
            _modifiers = new List<IScoreModifier>();
            _currentScore = 0;
            _comboCount = 0;
        }

        /// <summary>
        /// 점수 추가 (콤보 및 모디파이어 적용)
        /// </summary>
        /// <param name="basePoints">기본 점수</param>
        /// <returns>실제 추가된 점수 (배율 적용 후)</returns>
        public int AddScore(int basePoints)
        {
            if (basePoints <= 0)
                return 0;

            int previousScore = _currentScore;
            int finalPoints = CalculateFinalScore(basePoints, ScoreChangeType.Add);

            _currentScore += finalPoints;

            RaiseScoreChangedEvent(previousScore, _currentScore, ScoreChangeType.Add);

            return finalPoints;
        }

        /// <summary>
        /// 점수 감소 (모디파이어 적용, 콤보 무관)
        /// </summary>
        /// <param name="points">감소할 점수</param>
        /// <returns>실제 감소된 점수</returns>
        public int SubtractScore(int points)
        {
            if (points <= 0)
                return 0;

            int previousScore = _currentScore;
            int actualSubtraction = Math.Min(points, _currentScore);

            _currentScore -= actualSubtraction;

            RaiseScoreChangedEvent(previousScore, _currentScore, ScoreChangeType.Subtract);

            return actualSubtraction;
        }

        /// <summary>
        /// 콤보 증가 (연속 득점 시 호출)
        /// </summary>
        public void IncrementCombo()
        {
            int previousCombo = _comboCount;
            _comboCount++;

            RaiseComboChangedEvent(previousCombo, _comboCount, wasReset: false);
        }

        /// <summary>
        /// 콤보 리셋 (콤보 끊김 시 호출)
        /// </summary>
        public void ResetCombo()
        {
            int previousCombo = _comboCount;
            _comboCount = 0;

            RaiseComboChangedEvent(previousCombo, _comboCount, wasReset: true);
        }

        /// <summary>
        /// 점수 및 콤보 전체 리셋
        /// </summary>
        public void Reset()
        {
            int previousScore = _currentScore;
            int previousCombo = _comboCount;

            _currentScore = 0;
            _comboCount = 0;

            if (previousScore != 0)
            {
                RaiseScoreChangedEvent(previousScore, 0, ScoreChangeType.Subtract);
            }

            if (previousCombo != 0)
            {
                RaiseComboChangedEvent(previousCombo, 0, wasReset: true);
            }
        }

        /// <summary>
        /// 점수 모디파이어 등록
        /// </summary>
        public void RegisterModifier(IScoreModifier modifier)
        {
            if (modifier == null)
                throw new ArgumentNullException(nameof(modifier));

            if (!_modifiers.Contains(modifier))
            {
                _modifiers.Add(modifier);
            }
        }

        /// <summary>
        /// 점수 모디파이어 해제
        /// </summary>
        public void UnregisterModifier(IScoreModifier modifier)
        {
            if (modifier == null)
                throw new ArgumentNullException(nameof(modifier));

            _modifiers.Remove(modifier);
        }

        /// <summary>
        /// 최종 점수 계산 (콤보 + 모디파이어 적용)
        /// </summary>
        private int CalculateFinalScore(int basePoints, ScoreChangeType changeType)
        {
            var context = new ScoreContext(
                basePoints,
                _currentScore,
                _comboCount,
                ComboMultiplier,
                changeType);

            // 콤보 배율 적용
            float score = basePoints * ComboMultiplier;

            // 활성 모디파이어를 우선순위로 정렬
            var activeModifiers = _modifiers
                .Where(m => m.IsActive)
                .OrderBy(m => m.Priority)
                .ToList();

            // 모디파이어 적용 (가산 먼저, 배율 나중)
            int bonusPoints = 0;
            float totalMultiplier = 1.0f;

            foreach (var modifier in activeModifiers)
            {
                bonusPoints += modifier.ModifyScore(context);
                totalMultiplier *= modifier.ModifyMultiplier(context);
            }

            // 최종 계산: (기본점수 * 콤보배율 + 보너스) * 모디파이어배율
            score = (score + bonusPoints) * totalMultiplier;

            return Math.Max(0, (int)score);
        }

        private void RaiseScoreChangedEvent(int previousScore, int currentScore, ScoreChangeType changeType)
        {
            OnScoreChanged?.Invoke(new ScoreChangedEventArgs(previousScore, currentScore, changeType));
        }

        private void RaiseComboChangedEvent(int previousCombo, int currentCombo, bool wasReset)
        {
            OnComboChanged?.Invoke(new ComboChangedEventArgs(
                previousCombo,
                currentCombo,
                ComboMultiplier,
                wasReset));
        }
    }
}
