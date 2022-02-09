# Hatcha 🚇🚍
![alt text](https://user-images.githubusercontent.com/68496759/152849774-04a2632a-814b-4fc6-becb-bfdbb1ea7a57.png)
## 오디오 기반 하차 알림 앱

음성인식을 통해 실시간으로 현재 역을 알려주고, 설정한 하차 역에 도착했을 때 알림을 보내고자 하는 앱 입니다.

## 기능 🛠
- Realm을 통해 생성된 알람 저장
- 지하철 도착 역, 노선, 전 역 도착 알림 받기 여부 선택하여 알람 생성
- 버스 노선명, 도착 역, 전 역 도착 알림 받기 여부 선택하여 알람 생성
- 실시간 마이크 녹음으로 음성인식 진행
- 음성인식을 통해 안내방송 듣고 현재 역 표시
- 전 역/도착 역 도착 시, 진동과 함께 알림 보냄

## Tech 👨🏻‍💻

핫차는 아래의 라이브러리들을 사용합니다:
- DropDown - 드롭다운 라이브러리
- Realm - 데이터베이스
- AudioKit (AVAudioEngine, AVAudioPlayerNode, AVAudioUnitEQ, AVAudioSession) - 마이크 녹음 및 오디오 변환
- Speech - 음성인식 라이브러리

## 실행 화면 📱

| 메인 화면   | 정보 화면 ℹ️       |  지하철 도착역 선택화면    |
| ------------- | ------------- | ------------- |
| ![alt text](https://user-images.githubusercontent.com/68496759/153041825-69331f82-4d75-41b3-bec9-a6bd6df84242.png)  | ![alt text](https://user-images.githubusercontent.com/68496759/153041979-1ed0fc36-e67a-48ae-bbcb-a8385d092777.png)  | ![alt text](https://user-images.githubusercontent.com/68496759/153042002-94e4db7d-159d-49dd-b5cd-eb625c6ba0e8.png)  |

| 지하철 노선 선택화면  | 버스 노선 선택화면 | 버스 도착역 선택화면 |
| ------------- | ------------- | ------------- |
| ![alt text](https://user-images.githubusercontent.com/68496759/153042010-e2cedf50-f1c1-450f-822d-9f479a123e14.png)  | ![alt text](https://user-images.githubusercontent.com/68496759/153042017-f4d90914-1874-422b-be17-c8791963305e.png)  | ![alt text](https://user-images.githubusercontent.com/68496759/153042019-d769301e-b03c-4f6e-abe4-9064f5bd08f2.png) |

| 알람 활성화 상태 화면  | 전 역 도착 알림 |  목적지 도착 알림 |
| ------------- | ------------- | ------------- |
| ![alt text](https://user-images.githubusercontent.com/68496759/153042007-f18e491d-2ad1-4d35-88b6-bf4718c9d02a.png)  | ![alt text](https://user-images.githubusercontent.com/68496759/153044247-9aeb3e68-c7d4-4398-8625-f9c0655e9048.png)  | ![alt text](https://user-images.githubusercontent.com/68496759/153044282-8d65ddab-be5a-48b2-8098-ca0db619a22a.png)  |

Skills Used: MVC, AudioKit, SpeechRecognition, LocalNotification, Realm, Delegate Pattern
