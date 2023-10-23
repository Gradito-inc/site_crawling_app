/// アットホームの物件詳細ページからシミュレーション入力値を抽出するための設定です。
const parseSiteJsonAthome = r'''
  {
    "settingHouse": {
      "buildingName": {
        "selectors": [
          ".detail-header .title-page"
        ],
        "pattern": "\\S(.*\\S)?|\\S",
        "group": 0
      },
      "price": {
        "selectors": [
          "#content > section > div:nth-child(6) tr:nth-child(1) td",
          "#content > section > div:nth-child(7) tr:nth-child(1) td",
          "main > form > section > section:nth-child(15) tr:nth-child(1) td"
        ],
        "pattern": "(([0-9,]+)億)?([0-9,]+万)?([0-9,]+)?円",
        "group": 0
      },
      "prefecture": {
        "selectors": [
          "#content > section > div:nth-child(8) tr:nth-child(3) td",
          "#content > section > div:nth-child(9) tr:nth-child(2) td",
          "#content > section > div:nth-child(9) tr:nth-child(3) td",
          "main > form > section > section:nth-child(15) tr:nth-child(9) td"
        ],
        "pattern": "^([^都道府県]+[都道府県])",
        "group": 1
      },
      "areaLand": {
        "selectors": [
          "#content > section > div:nth-child(6) tr:nth-child(3) td",
          "#content > section > div:nth-child(7) tr:nth-child(4) td",
          "main > form > section > section:nth-child(15) tr:nth-child(8) td"
        ],
        "pattern": "([0-9]+(.[0-9]+)?)((m²)|(㎡)|(m2))",
        "group": 1
      },
      "areaBuilding": {
        "selectors": [
          "#content > section > div:nth-child(6) tr:nth-child(4) td",
          "#content > section > div:nth-child(7) tr:nth-child(3) td",
          "main > form > section > section:nth-child(15) tr:nth-child(7) td"
        ],
        "pattern": "([0-9]+(.[0-9]+)?)((m²)|(㎡)|(m2))",
        "group": 1
      },
      "ownership": {
        "selectors": [
          ".accordion-list tr:nth-child(2) td",
          "#content > section > section:nth-child(13) tr:nth-child(2) td",
          "main > form > section > div:nth-child(19) tr:nth-child(8) td",
          "#outlineSection > div.sectionItem.listStyle > ul > li:nth-child(1) > dl > dd:nth-child(20)"
        ],
        "pattern": ".+権",
        "group": 0
      },
      "dateYear": {
        "selectors": [
          "#content > section > div:nth-child(6) tr:nth-child(6) td",
          "#content > section > div:nth-child(7) tr:nth-child(6) td",
          "main > form > section > div:nth-child(20) tr:nth-child(2) td",
          "#outlineSection > div.sectionItem.listStyle > ul > li:nth-child(1) > dl > dd:nth-child(6)"
        ],
        "pattern": "(((明治)|(大正)|(昭和)|(平成)|(令和))?([0-9]+))年",
        "group": 1
      },
      "dateMonth": {
        "selectors": [
          "#content > section > div:nth-child(6) tr:nth-child(6) td",
          "#content > section > div:nth-child(7) tr:nth-child(6) td",
          "main > form > section > div:nth-child(20) tr:nth-child(2) td",
          "#outlineSection > div.sectionItem.listStyle > ul > li:nth-child(1) > dl > dd:nth-child(6)"
        ],
        "pattern": "([0-9]+)月",
        "group": 1
      }
    },
  }
''';
