class AcademicConstants {
  static const List<String> boards = ["GSEB", "CBSE"];

  static const Map<String, List<String>> standards = {
    "GSEB": [
      "6", "7", "8", "9", "10",
      "11 Science", "11 Commerce",
      "12 Science", "12 Commerce"
    ],
    "CBSE": [
      "6", "7", "8", "9", "10",
      "11 Science", "11 Commerce",
      "12 Science", "12 Commerce"
    ]
  };

  static const Map<String, List<String>> subjects = {
    "GSEB-6": ["Maths", "Science", "English", "Gujarati", "Hindi", "Social Science", "Computer"],
    "GSEB-7": ["Maths", "Science", "English", "Gujarati", "Hindi", "Social Science", "Computer"],
    "GSEB-8": ["Maths", "Science", "English", "Gujarati", "Hindi", "Social Science", "Computer"],
    "GSEB-9": ["Maths", "Science", "English", "Gujarati", "Hindi", "Social Science", "Computer"],
    "GSEB-10": ["Maths", "Science", "English", "Gujarati", "Hindi", "Social Science", "Computer"],

    "GSEB-11 Science": ["Physics", "Chemistry", "Biology", "Mathematics", "English", "Computer Science"],
    "GSEB-12 Science": ["Physics", "Chemistry", "Biology", "Mathematics", "English", "Computer Science"],

    "GSEB-11 Commerce": [
      "Accountancy",
      "Business Studies",
      "Economics",
      "Statistics",
      "English",
      "Organization of Commerce",
      "Secretarial Practice"
    ],
    "GSEB-12 Commerce": [
      "Accountancy",
      "Business Studies",
      "Economics",
      "Statistics",
      "English",
      "Organization of Commerce",
      "Secretarial Practice"
    ],

    "CBSE-6": ["Maths", "Science", "English", "Hindi", "Social Science", "Computer"],
    "CBSE-7": ["Maths", "Science", "English", "Hindi", "Social Science", "Computer"],
    "CBSE-8": ["Maths", "Science", "English", "Hindi", "Social Science", "Computer"],
    "CBSE-9": ["Maths", "Science", "English", "Hindi", "Social Science", "Computer"],
    "CBSE-10": ["Maths", "Science", "English", "Hindi", "Social Science", "Computer"],

    "CBSE-11 Science": ["Physics", "Chemistry", "Biology", "Mathematics", "English", "Computer Science"],
    "CBSE-12 Science": ["Physics", "Chemistry", "Biology", "Mathematics", "English", "Computer Science"],

    "CBSE-11 Commerce": [
      "Accountancy",
      "Business Studies",
      "Economics",
      "Mathematics",
      "English",
      "Informatics Practices"
    ],
    "CBSE-12 Commerce": [
      "Accountancy",
      "Business Studies",
      "Economics",
      "Mathematics",
      "English",
      "Informatics Practices"
    ],
  };

  static const List<String> mediums = ["English", "Gujarati"];
  static const List<String> marks = ["20", "30", "40"];
}
