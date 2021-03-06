//
//  SubwayStation.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2022/01/05.
//

import Foundation

struct Subway
{
    static let stations: [String: [String]] =
    [
        "01호선": ["소요산",    "동두천",    "보산",    "동두천중앙",    "지행",    "덕정",    "덕계",    "양주",    "녹양",    "기능",    "의정부",    "회룡",    "망월사",    "도봉산",    "도봉산",    "방학",    "녹천",    "월계",    "광운대",    "석계",    "신이문",    "외대앞",    "회기",    "청량리",    "제기동",    "신설동",    "동묘앞",    "동대문",    "종로5가",    "종로3가",    "종각",    "시청",    "서울역",    "남영",    "용산",    "노량진",    "대방",    "신길",    "영등포",    "신도림",    "구로",    "가산디지털단지",    "독산",    "금천구청",    "석수",    "관악",    "안양",    "명학",    "금정",    "군포",    "당정",    "의왕",    "성균관대",    "화서",    "수원",    "세류",    "병점",    "세마",    "서동탄",    "오산대",    "오산",    "진위",    "송탄",    "서정리",    "지제",    "평택",    "성환",    "직산",    "두정",    "천안",    "봉명",    "쌍용",    "아산",    "탕정",    "배방",    "풍기",    "온양온천",    "신창",    "구일",    "개봉",    "오류동",    "온수",    "역곡",    "소사",    "부천",    "중동",    "송내",    "부개",    "부평",    "백운",    "동암",    "간석",    "주안",    "도화",    "제물포",    "도원",    "동인천",    "인천",],
        "02호선": ["까치산",    "신정네거리",    "양천구청",    "도림천",    "신도림",    "대림",    "구로디지털단지",    "신대방",    "신림",    "봉천",    "서울대입구",    "낙성대",    "사당",    "방배",    "서초",    "교대",    "강남",    "역삼",    "선릉",    "삼성",    "종합운동장",    "신천",    "잠실",    "잠실나루",    "강변",    "구의",    "건대입구",    "성수",    "뚝섬",    "용답",    "한양대",    "왕십리",    "신답",    "용두",    "신설동",    "신당",    "상왕십리",    "동대문역사문화공원",    "을지로4가",    "을지로3가",    "을지로입구",    "시청",    "충정로",    "아현",    "이대",    "신촌",    "홍대입구",    "합정",    "당산",    "영등포구청",    "문래"],
        "03호선": ["대화",    "주엽",    "정발산",    "마두",    "백석",    "대곡",    "화정",    "원당",    "원흥",    "삼송",    "지축",    "구파발",    "연신내",    "불광",    "녹번",    "홍제",    "무악재",    "독립문",    "경복궁",    "안국",    "종로3가",    "을지로3가",    "충무로",    "동대입구",    "약수",    "금호",    "옥수",    "압구정",    "신사",    "잠원",    "고속터미널",    "교대",    "남부터미널",    "양재",    "매봉",    "도곡",    "대치",    "학여울",    "대청",    "일원",    "수서",    "가락시장",    "경찰병원",    "오금"],
        "04호선": ["당고개",    "상계",    "노원",    "창동",    "쌍문",    "수유",    "미아",    "미아사거리",    "길음",    "성신여대입구",    "한성대입구",    "혜화",    "동대문",    "동대문역사문화공원",    "충무로",    "명동",    "회현",    "숙대입구",    "삼각지",    "신용산",    "이촌",    "동작",    "총신대입구",    "남태령",    "선바위",    "경마공원",    "대공원",    "과천",    "정부과천청사",    "인덕원",    "평촌",    "범계",    "금정",    "산본",    "수리산",    "대야미",    "반월",    "상록수",    "한대앞",    "중앙",    "고잔",    "초지",    "안산",    "신길온천",    "정왕",    "오이도"],
        "05호선": ["하남검단산", "하남시청", "하남풍산", "미사", "강일", "상일동",    "고덕",    "명일",    "굽은다리",    "길동",    "강동",    "둔촌동",    "올림픽공원",    "방이",    "오금",    "개롱",    "거여",    "마천",    "천호",    "광나루",    "아차산",    "군자",    "장한평",    "답십리",    "마장",    "왕십리",    "행당",    "신금호",    "청구",    "광화문",    "서대문",    "충정로",    "애오개",    "공덕",    "마포",    "여의나루",    "여의도",    "영등포시장",    "양평",    "오목교",    "목동",    "신정",    "화곡",    "우장산",    "발산",    "마곡",    "송정",    "김포공항",    "개화산",    "방화"],
        "06호선": ["신내", "봉화산",    "화랑대",    "태릉입구",    "돌곶이",    "상월곡",    "월곡",    "고려대",    "안암",    "보문",    "창신", "동묘앞", "신당", "청구", "약수", "버티고개",    "한강진",    "이태원",    "녹사평", "삼각지",   "효창공원앞", "공덕",   "대흥",    "광흥창",    "상수", "합정",   "망원",    "마포구청",    "월드컵경기장",    "디지털미디어시티",    "증산",    "새절",    "응암",    "구산",  "연신내",  "독바위",    "불광",    "역촌"],
        "07호선": ["장암",    "도봉산",    "수락산",    "마들",    "중계",    "하계",    "공릉",    "먹골",    "중화",    "상봉",    "면목",    "사가정",    "용마산",    "중곡",    "군자", "어린이대공원", "건대입구",   "뚝섬유원지",    "청담", "강남구청",   "학동",    "논현",    "반포",    "고속터미널", "내방", "이수",   "남성",    "숭실대입구",    "상도",    "장승배기",    "신대방삼거리",    "보라매",    "신풍", "대림",   "남구로",  "가산디지털단지",   "철산",    "광명사거리",    "천왕", "온수",   "까치울",    "부천종합운동장",    "춘의",    "신중동",    "부천시청",    "상동",    "삼산체육관",    "굴포천",    "부평구청", "산곡", "석남"],
        "08호선": ["암사", "천호", "강동구청", "몽촌토성", "잠실", "석촌", "송파", "가락시장", "문정", "장지", "복정",  "남위례",   "산성", "남한산성입구", "단대오거리", "신흥", "수진",  "모란"],
        "09호선": ["개화", "김포공항", "공항시장", "신방화", "마곡나루", "양천향교", "가양", "증미", "등촌", "염창", "선유도", "당산", "국회의사당", "여의도", "샛강", "노량진", "노들", "흑석", "동작", "구반포", "신반포", "고속터미널", "사평", "신논현", "언주", "선정릉", "신목동", "삼성중앙", "봉은사", "종합운동장", "삼전", "석촌고분", "석촌", "송파나루", "한성백제", "올림픽공원", "둔촌오륜", "중앙보훈병원"],
        "경춘선": ["춘천","남춘천", "김유정","강촌","백양리", "상천", "청평","굴봉산","대성리", "마석", "천마산", "평내호평", "금곡", "사릉","퇴계원", "별내", "갈매", "신내","망우","상봉", "중랑","회기", "청량리", "상봉", "광운대"],
        "수인분당선": ["왕십리",    "서울숲",    "압구정로데오",    "강남구청",    "선정릉",    "선릉",    "한티",    "도곡",    "구룡",    "개포동",    "대모산입구",    "수서",    "복정",    "가천대",    "태평",    "모란",    "야탑",    "이매",    "서현",    "수내",    "정자",    "미금",    "오리",    "죽전",    "보정",    "구성",    "신갈",    "기흥",    "상갈",    "청명",    "영통",    "망포",    "매탄권선",    "수원시청",    "매교",    "수원시청",    "고색",    "오목천",    "어천",    "야목",    "사리",    "한대앞",    "중앙",    "고잔",    "초지",    "안산",    "신길오천",    "정왕",    "오이도",    "달월",    "월곶",    "소래포구",    "인천논현",    "호구포",    "남동인더스파크",    "원인재",    "연수",    "송도",    "인하대",    "숭의",    "신포",    "인천"],
        "신분당선": ["강남",    "양재",    "양재시민의 숲",    "청계산입구",    "판교",    "정자",    "미금",    "동천",    "수지구청",    "성복",    "상현",    "광교중앙",    "광교"],
        "서해선": ["소사", "소새울", "시흥대야", "신천", "신현", "시흥시청", "시흥능곡", "달미", "선부", "초지", "시우", "원시"],
        "공항철도": ["서울역", "공덕", "홍대입구", "디지털미디어시티", "마곡나루", "김포공항", "계양", "검암", "청라국제도시", "영종", "운서", "공항화물청사", "인천공항1터미널", "인천공항2터미널"],
        "경의선": ["임진강",    "문산",    "파주",    "월롱",    "금촌",    "금릉",    "운정",    "야당",    "탄현",    "일산",    "풍산",    "백마",    "곡산",    "대곡",    "능곡",    "행신",    "강매",    "화전",    "수색",    "미지털미디어시티",    "가좌",    "홍대입구",    "서강대",    "공덕",    "효창공원앞",    "용산",    "이촌",    "서빙고",    "한남",    "옥수",    "응봉",    "왕십리",    "청량리",    "회기",    "중랑",    "상봉",    "망우",    "양원",    "구리",    "도농",    "양정",    "덕소",    "도심",    "팔당",    "운길산",    "양수",    "신원",    "국수",    "아신",    "오빈",    "양평",    "원덕",    "용문",    "지평",    "신촌",    "서울역"],
        "의정부경전철": ["탑석",    "송산",    "어룡",    "곤제",    "효자",    "경기도청 북부청사",    "새말",    "동오",    "의정부 중앙",    "흥선",    "의정부 시청",    "경전철 의정부",    "범골",    "희룡",    "발곡"],
        "김포도시철도": ["양촌", "구래", "마산", "장기", "운양", "걸포북변", "사우", "풍무", "고촌", "김포공항"],
        "경강선": ["판교", "이매", "삼동", "경기광주", "초월", "곤지암", "신둔도예촌", "이천", "부발", "세종대왕릉", "여주"],
        "우이신설경전철": ["북한산우이", "솔밭공원", "4·19민주묘지", "가오리", "화계", "삼양", "삼양사거리", "솔샘", "북한산보국문", "정릉", "성신여대입구", "보문", "신설동"],
        "인천선": ["계양",    "귤현",    "박촌",    "임학",    "계산",    "경인교대입구",    "작전",    "갈산",    "부평구청",    "부평시장",    "부평",    "동수",    "부평삼거리",    "간석오거리",    "인천시청",    "예술회관",    "인천터미널",    "문학경기장",    "선학",    "신연수",    "원인재",    "동춘",    "동막",    "캠퍼스타운",    "테크노파크",    "지식정보단지",    "인천대입구",    "센트럴파크",    "국제업무지구",    "송도달빛축제공원"],
        "인천2호선": ["검단오류",    "왕길",    "검단사거리",    "마전",    "완정",    "독정",    "검암",    "검바위",    "아시아드 경기장",    "서구청",    "가정",    "가정중앙시장",    "석남",    "서부여성회관",    "인천가좌",    "가재울",    "주안국가산단",    "주안국가산단",    "시민공원",    "석바위 시장",    "인천시청",    "석천사거리",    "모래내시장",    "만수",    "남동구청",    "인천대공원",    "운연"],
        "용인경전철": ["기흥",    "강남대",    "지석",    "어정",    "동백",    "초당",    "삼가",    "시청.용인대",    "명지대",    "김량장",    "운동장.송담대",    "고진",    "보평",    "둔전",    "전대.에버랜드"]]
}

