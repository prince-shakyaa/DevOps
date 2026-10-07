"""Pure grading logic for the campus grade API - no Flask imports here so it is easy to unit test."""

# (lower bound of the band, letter, grade points) on a 10-point scale, highest band first
GRADE_BANDS = [
    (90, "O", 10),
    (80, "A+", 9),
    (70, "A", 8),
    (60, "B+", 7),
    (50, "B", 6),
    (40, "C", 5),
    (0, "F", 0),
]


def letter_grade(marks):
    """Return (letter, grade_points) for marks out of 100."""
    if not isinstance(marks, (int, float)) or isinstance(marks, bool):
        raise TypeError("marks must be a number")
    if marks < 0 or marks > 100:
        raise ValueError("marks must be between 0 and 100")
    for lower, letter, points in GRADE_BANDS:
        if marks >= lower:
            return letter, points
    raise AssertionError("unreachable")  # pragma: no cover


def sgpa(courses):
    """Credit-weighted grade point average for a list of {"marks": .., "credits": ..} dicts."""
    if not courses:
        raise ValueError("at least one course is required")
    total_credits = 0
    weighted = 0
    for course in courses:
        credits = course.get("credits")
        if not isinstance(credits, int) or isinstance(credits, bool) or credits <= 0:
            raise ValueError("credits must be a positive integer")
        _, points = letter_grade(course.get("marks"))
        total_credits += credits
        weighted += points * credits
    return round(weighted / total_credits, 2)


def is_pass(marks):
    """A course is passed with marks of 40 or more."""
    return letter_grade(marks)[1] > 0
