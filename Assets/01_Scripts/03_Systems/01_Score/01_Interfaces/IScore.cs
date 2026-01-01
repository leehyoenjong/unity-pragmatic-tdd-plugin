// IScore.cs
// Score System Interfaces - Alpha Stage (SOLID 적극 적용)

using System;
using System.Collections.Generic;

namespace Systems.Score
{
    /// <summary>
    /// Score 시스템의 핵심 계약
    /// 점수 관리의 기본 기능을 정의합니다.
    /// </summary>
    public interface IScoreSystem
    {
        /// <summary>
        /// 현재 점수
        /// </summary>
        int CurrentScore { get; }

        /// <summary>
        /// 현재 콤보 카운트
        /// </summary>
        int ComboCount { get; }

        /// <summary>
        /// 현재 적용 중인 콤보 배율
        /// </summary>
        float ComboMultiplier { get; }

        /// <summary>
        /// 점수 추가 (콤보 및 모디파이어 적용)
        /// </summary>
        /// <param name="basePoints">기본 점수</param>
        /// <returns>실제 추가된 점수 (배율 적용 후)</returns>
        int AddScore(int basePoints);

        /// <summary>
        /// 점수 감소 (모디파이어 적용, 콤보 무관)
        /// </summary>
        /// <param name="points">감소할 점수</param>
        /// <returns>실제 감소된 점수</returns>
        int SubtractScore(int points);

        /// <summary>
        /// 콤보 증가 (연속 득점 시 호출)
        /// </summary>
        void IncrementCombo();

        /// <summary>
        /// 콤보 리셋 (콤보 끊김 시 호출)
        /// </summary>
        void ResetCombo();

        /// <summary>
        /// 점수 및 콤보 전체 리셋
        /// </summary>
        void Reset();

        /// <summary>
        /// 점수 모디파이어 등록
        /// </summary>
        void RegisterModifier(IScoreModifier modifier);

        /// <summary>
        /// 점수 모디파이어 해제
        /// </summary>
        void UnregisterModifier(IScoreModifier modifier);

        /// <summary>
        /// 점수 변경 이벤트
        /// </summary>
        event Action<ScoreChangedEventArgs> OnScoreChanged;

        /// <summary>
        /// 콤보 변경 이벤트
        /// </summary>
        event Action<ComboChangedEventArgs> OnComboChanged;
    }

    /// <summary>
    /// 확장 포인트: 점수 계산에 영향을 주는 모디파이어
    /// Beta/Live에서 새로운 점수 보너스/페널티 추가 시 이 인터페이스 구현
    /// </summary>
    /// <example>
    /// - DoubleScoreModifier: 이벤트 기간 2배 점수
    /// - VIPBonusModifier: VIP 유저 보너스
    /// - DifficultyModifier: 난이도별 점수 배율
    /// </example>
    public interface IScoreModifier
    {
        /// <summary>
        /// 모디파이어 식별자
        /// </summary>
        string Id { get; }

        /// <summary>
        /// 적용 우선순위 (낮을수록 먼저 적용)
        /// </summary>
        int Priority { get; }

        /// <summary>
        /// 모디파이어 활성화 여부
        /// </summary>
        bool IsActive { get; }

        /// <summary>
        /// 점수 수정 (가산 방식)
        /// </summary>
        /// <param name="context">점수 계산 컨텍스트</param>
        /// <returns>추가/감소할 점수</returns>
        int ModifyScore(ScoreContext context);

        /// <summary>
        /// 배율 수정 (승산 방식)
        /// </summary>
        /// <param name="context">점수 계산 컨텍스트</param>
        /// <returns>적용할 배율 (1.0 = 변화 없음)</returns>
        float ModifyMultiplier(ScoreContext context);
    }

    /// <summary>
    /// 확장 포인트: 콤보 배율 계산 전략
    /// 다양한 콤보 배율 공식을 적용할 수 있음
    /// </summary>
    public interface IComboStrategy
    {
        /// <summary>
        /// 콤보 카운트에 따른 배율 계산
        /// </summary>
        /// <param name="comboCount">현재 콤보 카운트</param>
        /// <returns>적용할 배율</returns>
        float CalculateMultiplier(int comboCount);

        /// <summary>
        /// 최대 콤보 배율
        /// </summary>
        float MaxMultiplier { get; }
    }

    /// <summary>
    /// 점수 계산 시 전달되는 컨텍스트 정보
    /// </summary>
    public readonly struct ScoreContext
    {
        /// <summary>
        /// 기본 점수 (모디파이어 적용 전)
        /// </summary>
        public int BasePoints { get; }

        /// <summary>
        /// 현재 총 점수
        /// </summary>
        public int CurrentScore { get; }

        /// <summary>
        /// 현재 콤보 카운트
        /// </summary>
        public int ComboCount { get; }

        /// <summary>
        /// 콤보 배율
        /// </summary>
        public float ComboMultiplier { get; }

        /// <summary>
        /// 점수 변경 타입 (추가/감소)
        /// </summary>
        public ScoreChangeType ChangeType { get; }

        public ScoreContext(
            int basePoints,
            int currentScore,
            int comboCount,
            float comboMultiplier,
            ScoreChangeType changeType)
        {
            BasePoints = basePoints;
            CurrentScore = currentScore;
            ComboCount = comboCount;
            ComboMultiplier = comboMultiplier;
            ChangeType = changeType;
        }
    }

    /// <summary>
    /// 점수 변경 타입
    /// </summary>
    public enum ScoreChangeType
    {
        Add,
        Subtract
    }

    /// <summary>
    /// 점수 변경 이벤트 인자
    /// </summary>
    public class ScoreChangedEventArgs : EventArgs
    {
        /// <summary>
        /// 이전 점수
        /// </summary>
        public int PreviousScore { get; }

        /// <summary>
        /// 현재 점수
        /// </summary>
        public int CurrentScore { get; }

        /// <summary>
        /// 변경량 (양수: 증가, 음수: 감소)
        /// </summary>
        public int Delta { get; }

        /// <summary>
        /// 변경 타입
        /// </summary>
        public ScoreChangeType ChangeType { get; }

        public ScoreChangedEventArgs(
            int previousScore,
            int currentScore,
            ScoreChangeType changeType)
        {
            PreviousScore = previousScore;
            CurrentScore = currentScore;
            Delta = currentScore - previousScore;
            ChangeType = changeType;
        }
    }

    /// <summary>
    /// 콤보 변경 이벤트 인자
    /// </summary>
    public class ComboChangedEventArgs : EventArgs
    {
        /// <summary>
        /// 이전 콤보 카운트
        /// </summary>
        public int PreviousCombo { get; }

        /// <summary>
        /// 현재 콤보 카운트
        /// </summary>
        public int CurrentCombo { get; }

        /// <summary>
        /// 현재 콤보 배율
        /// </summary>
        public float Multiplier { get; }

        /// <summary>
        /// 콤보가 리셋되었는지 여부
        /// </summary>
        public bool WasReset { get; }

        public ComboChangedEventArgs(
            int previousCombo,
            int currentCombo,
            float multiplier,
            bool wasReset = false)
        {
            PreviousCombo = previousCombo;
            CurrentCombo = currentCombo;
            Multiplier = multiplier;
            WasReset = wasReset;
        }
    }
}
