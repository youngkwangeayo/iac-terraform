추가작업

테스크패밀리에 지표활성화 클라우드워치- OTEL Collector 컨테이너 자동생김.

태스크- 역할 ecsTaskRole 에 클라우드워치 정책추가해야함.
  --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy



향상된 관찰성을 갖춘 Container Insights 해당 모니터링으로 설정
(클러스터 및 서비스 수준에서 집계된 지표 외에도 작업 및 컨테이너 수준에서 상세한 상태 및 성능 지표를 제공합니다. 더 쉽게 드릴 다운하여 문제를 더 빠르게 격리하고 해결할 수 있습니다.)



---
임시 참고용
e636d5e0d6a0473eab0b7e95bbec150e