import pytest

from app.grading import is_pass, letter_grade, sgpa


@pytest.mark.parametrize(
    "marks, expected",
    [(100, ("O", 10)), (90, ("O", 10)), (89.5, ("A+", 9)), (75, ("A", 8)), (60, ("B+", 7)),
     (55, ("B", 6)), (40, ("C", 5)), (39.9, ("F", 0)), (0, ("F", 0))],
)
def test_letter_grade_bands(marks, expected):
    assert letter_grade(marks) == expected


@pytest.mark.parametrize("marks", [-1, 100.1, 250])
def test_letter_grade_out_of_range(marks):
    with pytest.raises(ValueError):
        letter_grade(marks)


@pytest.mark.parametrize("marks", ["90", None, True])
def test_letter_grade_rejects_non_numbers(marks):
    with pytest.raises(TypeError):
        letter_grade(marks)


def test_sgpa_is_credit_weighted():
    courses = [{"marks": 92, "credits": 4}, {"marks": 71, "credits": 3}, {"marks": 55, "credits": 1}]
    # (10*4 + 8*3 + 6*1) / 8 = 8.75
    assert sgpa(courses) == 8.75


def test_sgpa_needs_courses():
    with pytest.raises(ValueError):
        sgpa([])


@pytest.mark.parametrize("credits", [0, -2, 1.5, None])
def test_sgpa_rejects_bad_credits(credits):
    with pytest.raises(ValueError):
        sgpa([{"marks": 80, "credits": credits}])


def test_is_pass():
    assert is_pass(40) is True
    assert is_pass(39) is False
