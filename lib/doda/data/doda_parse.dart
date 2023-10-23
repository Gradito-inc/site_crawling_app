class DodaParse {
  const DodaParse();

  // dodaの求人一覧ページから企業を抽出するためのセレクタです。
  static const selectors = [
    '#shStart > div > div > div.middle.clrFix > div.box01 > dl:nth-child(1)',
    '#shStart > div > div > div.middle.clrFix > div.box01 > dl:nth-child(2)',
    '#shStart > div > div > div.middle.clrFix > div.box01 > dl:nth-child(3)',
    '#shStart > div > div > div.middle.clrFix > div.box01 > dl:nth-child(4)',
    '#shStart > div > div > div.middle.clrFix > div.box01 > dl:nth-child(5)',
    '#shStart > div > div > div.middle.clrFix > div.box01 > dl:nth-child(6)',
  ];

  static const idSelector =
      '#shStart > div:nth-child(22) > div > div.upper.clrFix > h2';

// dodaのアプリ開発求人url1ページ目
  static const initialUrl =
      'https://doda.jp/DodaFront/View/JobSearchList.action?k=%E3%82%B9%E3%83%9E%E3%83%BC%E3%83%88%E3%83%95%E3%82%A9%E3%83%B3%E3%82%A2%E3%83%97%E3%83%AA%E9%96%8B%E7%99%BA&kwc=1&pr=11%2C12%2C13%2C14&ss=1&pic=1&ds=0&tp=1&bf=1&mpsc_sid=10&oldestDayWdtno=0&leftPanelType=1&usrclk_searchList=PC-logoutJobSearchList_searchConditionArea_searchButtonFloat-locPrefecture-kwdInclude';

// idから企業詳細ページを取得する
  static String getDetailUrl(String id) =>
      'https://doda.jp/DodaFront/View/JobSearchDetail/j_jid__$id/-tab__jd/-fm__jobdetail/-mpsc_sid__10/-tp__1/';
}
