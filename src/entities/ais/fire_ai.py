from src.engine.acting.actions.splash_attack import SplashAttack


class FireAi:
    def make_decision(self, subject, perception):
        return SplashAttack(subject.p, 0)
