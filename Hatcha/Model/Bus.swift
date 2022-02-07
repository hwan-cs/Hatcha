//
//  File.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2022/01/31.
//

import Foundation

struct Bus
{
    static let stations: [String] =
    ["0017", "01A", "01B", "02", "04", "100", "101", "1014", "1017", "102", "1020", "103", "104", "105", "106", "107", "108", "109", "110A고려대", "110B국민대", "1111", "1113", "1114", "1115", "1116", "1119", "1120", "1122", "1124", "1126", "1127", "1128", "1129", "1130", "1131", "1132", "1133", "1135", "1136", "1137", "1138", "1139", "1140", "1141", "1142", "1143", "1144", "1154", "1155", "1156", "1162", "1164", "1165", "1167", "120", "121", "1213", "1218", "1221", "1222", "1224", "1226", "1227", "130", "140", "141", "142", "143", "144", "145", "146", "147", "148", "150", "151", "152", "153", "160", "162", "171", "1711", "172", "173", "201", "2012", "2013", "2014", "2015", "2016", "202", "2112", "2113", "2114", "2115", "2211", "2221", "2222", "2224", "2227", "2230", "2233", "2234", "2235", "2311", "2312", "240", "241", "2412", "2413", "2415", "242", "260", "261", "262", "270", "271", "272", "273", "301", "3011", "3012", "302", "303", "320", "3212", "3214", "3216", "3217", "3220", "3313", "3314", "3315", "3316", "3317", "3318", "3319", "3321", "3322", "333", "340", "341", "3411", "3412", "3413", "3414", "3416", "3417", "342", "3422", "3425", "3426", "343", "350", "360", "362", "370", "400", "401", "402", "405", "406", "420", "421", "4211", "4212", "4312", "4318", "4319", "440", "441", "4419", "4432", "4433", "4435", "452", "461", "463", "470", "472", "500", "501", "5012", "502", "503", "504", "505", "506", "507", "540", "541", "5413", "542", "5511", "5513", "5515", "5516", "5517", "5519", "5522A난곡", "5522B호암", "5523", "5524", "5525", "5528", "5530", "5531", "5535", "5536", "5537", "5615", "5616", "5617", "5618", "5619", "5620", "5621", "5623", "5624", "5625", "5626", "5627", "5630", "5633", "5634", "571", "5712", "5713", "5714", "600", "6009", "601", "602", "603", "604", "605", "606", "6100", "6101", "6211", "640", "641", "6411", "643", "650", "651", "6511", "6512", "6513", "6514", "6515", "6516", "652", "653", "654", "660", "661", "6611", "6613", "6614", "6615", "6616", "6617", "662", "6620", "6623", "6624", "6625", "6627", "6628", "6629", "6630", "6631", "6632", "6635", "6637", "6638", "6640A", "6640B", "6642", "6645", "6647", "6648", "6649", "6654", "6657", "6712", "6714", "6715", "6716", "672", "673", "674", "700", "701", "7011", "7013A", "7013B", "7016", "7017", "7018", "7019", "7021", "7022", "7024", "7025", "702A서오릉", "702B용두초교", "704", "705", "707", "708", "710", "720", "721", "7211", "7212", "740", "741", "742", "750A", "750B", "752", "753", "761", "7611", "7612", "7613", "771", "7711", "7713", "7715", "7719", "7720", "7722", "7723", "7726", "7727", "7728", "773", "7730", "7734", "7737", "7738", "7739", "774", "8002", "8003", "8112", "8221", "8331", "8441", "8541", "8551", "8552", "8761", "8771", "8772", "8774", "8777", "9401", "9403", "9404", "9408", "9701", "9703", "9707", "9711", "9714", "N13", "N15", "N16", "N26", "N30", "N37", "N61", "N62", "N65", "TOUR01", "TOUR02", "TOUR03", "TOUR04", "TOUR11", "TOUR12", "강남01", "강남02", "강남03", "강남05", "강남06", "강남06-1", "강남06-2", "강남07", "강남08", "강남10", "강동01", "강동02", "강동05", "강북01", "강북02", "강북03", "강북04", "강북05", "강북06", "강북08", "강북09", "강북10", "강북11", "강북12", "강서01", "강서02", "강서03", "강서04", "강서05", "강서05-1", "강서06", "강서07", "관악01", "관악02", "관악03", "관악04", "관악05", "관악06", "관악07", "관악08", "관악10", "관악11", "광진01", "광진02", "광진03", "광진04", "광진05", "구로01", "구로02", "구로03", "구로04", "구로05", "구로06", "구로07", "구로08", "구로09", "구로10", "구로11", "구로12", "구로13", "구로14", "구로15", "금천01", "금천02", "금천03", "금천04", "금천05", "금천06", "금천07", "금천08", "금천11", "노원01", "노원02", "노원03", "노원04", "노원05", "노원08", "노원09", "노원11", "노원13", "노원14", "노원15", "도봉01", "도봉02", "도봉03", "도봉04", "도봉05", "도봉06", "도봉07", "도봉08", "도봉09", "동대문01", "동대문02", "동대문03", "동대문05", "동작01", "동작02", "동작03", "동작05", "동작05-1", "동작06", "동작07", "동작08", "동작09", "동작10", "동작11", "동작12", "동작13", "동작14", "동작15", "동작16", "동작17", "동작18", "동작19", "동작20", "동작21", "마포01", "마포02", "마포03", "마포05", "마포06", "마포07", "마포08", "마포09", "마포10", "마포11", "마포12", "마포13", "마포14", "마포15", "마포16", "마포17", "마포18", "마포18-1", "서대문01", "서대문02대", "서대문02소", "서대문03", "서대문04", "서대문05", "서대문06", "서대문07", "서대문08", "서대문09대", "서대문09소", "서대문10", "서대문11", "서대문12", "서대문13", "서대문14", "서대문15", "서초01", "서초02", "서초03", "서초05", "서초06", "서초07", "서초08", "서초09", "서초10", "서초11", "서초13", "서초14", "서초15", "서초16", "서초17", "서초18", "서초18-1", "서초20", "서초21", "서초22", "성동01", "성동02", "성동03-1", "성동03-2", "성동05", "성동06", "성동07", "성동08", "성동09", "성동10", "성동12", "성동13", "성동14", "성북01", "성북02", "성북03", "성북04", "성북05", "성북06", "성북07", "성북08", "성북09", "성북10-1", "성북10-2", "성북12", "성북13", "성북14-1", "성북14-2", "성북15", "성북20", "성북21", "성북22", "양천01", "양천02", "양천03", "양천04", "영등포01", "영등포02", "영등포03", "영등포04", "영등포05", "영등포06", "영등포07", "영등포08", "영등포09", "영등포10", "영등포11", "영등포12", "영등포13", "용산01", "용산02", "용산03", "용산04", "은평01", "은평02", "은평03", "은평04", "은평05", "은평06", "은평07", "은평08-1", "은평08-2", "은평09", "은평10", "종로01", "종로02", "종로03", "종로05", "종로07", "종로08", "종로09", "종로11", "종로12", "종로13", "중랑01", "중랑02"]
}