// LinearComboStrategy.cs
// 선형 콤보 배율 전략 - combo * multiplierPerCombo 방식

using System;

namespace Systems.Score
{
    /// <summary>
    /// 선형 콤보 배율 전략
    /// 콤보 카운트에 비례하여 배율이 선형적으로 증가합니다.
    ///
    /// 공식: multiplier = 1.0 + (comboCount * multiplierPerCombo)
    /// 예: combo 3, multiplierPerCombo 0.1 → multiplier = 1.3
    /// </summary>
    public class LinearComboStrategy : IComboStrategy
    {
        private readonly float _multiplierPerCombo;
        private readonly float _maxMultiplier;

        /// <summary>
        /// 최대 콤보 배율
        /// </summary>
        public float MaxMultiplier => _maxMultiplier;

        /// <summary>
        /// LinearComboStrategy 생성자
        /// </summary>
        /// <param name="multiplierPerCombo">콤보 당 증가 배율 (기본값: 0.1)</param>
        /// <param name="maxMultiplier">최대 배율 (기본값: 5.0)</param>
        public LinearComboStrategy(float multiplierPerCombo = 0.1f, float maxMultiplier = 5.0f)
        {
            if (multiplierPerCombo < 0)
                throw new ArgumentException("multiplierPerCombo must be non-negative", nameof(multiplierPerCombo));
            if (maxMultiplier < 1.0f)
                throw new ArgumentException("maxMultiplier must be at least 1.0", nameof(maxMultiplier));

            _multiplierPerCombo = multiplierPerCombo;
            _maxMultiplier = maxMultiplier;
        }

        /// <summary>
        /// 콤보 카운트에 따른 배율 계산
        /// </summary>
        /// <param name="comboCount">현재 콤보 카운트</param>
        /// <returns>적용할 배율 (1.0 ~ MaxMultiplier)</returns>
        public float CalculateMultiplier(int comboCount)
        {
            if (comboCount <= 0)
                return 1.0f;

            float multiplier = 1.0f + (comboCount * _multiplierPerCombo);
            return Math.Min(multiplier, _maxMultiplier);
        }
    }
}
