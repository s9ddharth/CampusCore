from __future__ import annotations

from seed.seed_assessments import seed_assessments
from seed.seed_marks import seed_marks


def main() -> None:
    seed_assessments()
    seed_marks()

    print("ACADEMIC SEED COMPLETE")


if __name__ == "__main__":
    main()