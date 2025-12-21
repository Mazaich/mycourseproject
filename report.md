
Курсовой проект на профессии «DevOps-инженер с нуля» - Машаев Роман

   Цель проекта:
Реализовать отказоустойчивую и масштабируемую архитектуру веб-сервиса с использованием двух backend-серверов 
и балансировщика нагрузки (Application Load Balancer) для распределения трафика и проверки здоровья инстансов.

   Реализация (краткое техническое описание):
На двух виртуальных машинах в разных зонах доступности (web1 в ru-central1-a, web2 в ru-central1-b) развёрнут веб-сервер nginx со статичным сайтом. 
Для распределения запросов создан Application Load Balancer , который направляет трафик на целевую группу (Target Group), содержащую эти ВМ. 
Настроена проверка здоровья (healthcheck) по пути / на порту 80.

Детальный отчет по выполнению,демонстрация работы инфраструктуры:

1. Сайт и балансировщик.

curl -v http://158.160.198.162:80

![Скриншот работы балансировщика](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/Screenshot_2025-12-20_16_42_32.png?raw=true)
В выводе команды curl видно, что сайт работает (HTTP/1.1 200 OK), а Yandex Application Load Balancer идентифицирует себя через заголовок server: ycalb, 
что подтверждает прохождение трафика через балансировщик.

![Скриншот рыботы балансировщика](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/2025-12-21_04-08-05.png?raw=true)
![Скриншот работы балансировщика](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/Screenshot_2025-12-20_16_50_37.png?raw=true)
![Скриншот состояния таргет групп](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/2025-12-20_16-36-05.png?raw=true)
![Скриншот рыботы балансировщика](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/2025-12-21_04-08-05.png?raw=true)
![Скриншот рыботы балансировщика бэкенды](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/2025-12-21_04-08-43.png?raw=true)
![Скриншот рыботы балансировщика целевые группы](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/2025-12-21_04-08-55.png?raw=true)

Демонстрация фактического распределения нагрузки между двумя разными серверами:
![Скриншот рыботы балансировщика распределение нагрузки](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/Screenshot_2025-12-21_04_20_56.png?raw=true)

2.Мониторинг (Prometheus/Grafana) 

Ссылка на сайт: http://89.169.191.199:3000 

![Скриншот работы прометеус](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/Screenshot_2025-12-20_18_36_11.png?raw=true)
![Скриншот работы прометеус](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/Screenshot_2025-12-20_18_24_55.png?raw=true)
![Скриншот работы графана](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/Screenshot_2025-12-21_06_51_54.png?raw=true)
![Скриншот работы графана](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/Screenshot_2025-12-21_06_52_30.png?raw=true)
![Скриншот работы графана](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/Screenshot_2025-12-21_06_52_35.png?raw=true)
![Скриншот работы графана](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/Screenshot_2025-12-21_06_52_41.png?raw=true)
![Скриншот работы графана](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/Screenshot_2025-12-21_06_52_45.png?raw=true)
3. Логи (Elasticsearch/Kibana)

Ссылка на сайт: http://130.193.40.133:5601/app/management/kibana/indexPatterns/patterns/3924edc0-dda1-11f0-ac72-7d8c23a4d11c#/?_a=(tab:indexedFields)
![Скриншот Проверка индексов в Elasticsearch через Bastion](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/Screenshot_2025-12-21_02_33_35.png?raw=true)
![Скриншот работы Веб-интерфейса Kibana](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/Screenshot_2025-12-21_02_35_19.png?raw=true)
![Скриншот работы Discover с выбранным filebeat-* индексом и логами nginx](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/Screenshot_2025-12-21_02_35_37.png?raw=true)

4. Сеть и безопасность

![Скриншот схемы VPC с подсетями (приватные и публичные),правил Security Group](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/2025-12-21_03-04-06.png?raw=true)
![Скриншот схемы VPC с подсетями (приватные и публичные),правил Security Group](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/2025-12-21_03-04-32.png?raw=true)
![Скриншот схемы VPC с подсетями (приватные и публичные),правил Security Group](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/2025-12-21_03-05-12.png?raw=true)
![Скриншот схемы VPC с подсетями (приватные и публичные),правил Security Group](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/2025-12-21_03-13-56.png?raw=true)
![Скриншот схемы VPC с подсетями (приватные и публичные),правил Security Group](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/2025-12-21_03-14-44.png?raw=true)

Чтобы подтвердить, что веб-сервера изолированы в приватной сети и доступны только через бастион, было выполнено прямое подключение 
с локальной рабочей станции с использованием прыжка через бастион (SSH ProxyJump):
ssh -J ubuntu@158.160.97.89 ubuntu@192.168.30.23 "hostname"
Результат выполнения команды: fhm2a7vgmqglj0hqlh2u
Пояснение: успешное выполнение команды, возвращающей имя хоста внутреннего веб-сервера, доказывает работоспособность бастион-хоста 
как единственного контролируемого входа в инфраструктуру, корректную настройку сетевых правил (Security Groups), разрешающих SSH-трафик 
от бастиона к веб-серверам, изоляцию веб-серверов — прямое подключение к ним из интернета невозможно, что соответствует принципам безопасной архитектуры.
![Скриншот работы](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/Screenshot_2025-12-21_03_25_27.png?raw=true)

5. Резервное копирование

Для автоматизации процесса резервного копирования использовался ресурс Yandex Cloud yandex_compute_snapshot_schedule, настроенный с помощью Terraform.
Была создана единая политика снапшотов, которая: применяется ко всем виртуальным машинам проекта через указание метки (label) backup: "true", 
добавленной к каждому диску. Выполняется ежедневно в 02:00 по UTC. Хранит копии в течение 7 дней, после чего старые снапшоты автоматически 
удаляются для оптимизации затрат на хранение.

![Скриншот списока снапшотов дисков всех виртуальных машин в разделе Compute → Snapshots](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/2025-12-21_03-43-35.png?raw=true)
![Скриншот политики снапшотов daily-vm-backup с указанием ежедневного расписания и срока хранения 7 дней](https://github.com/Mazaich/mycourseproject/blob/main/screenshots/2025-12-21_03-44-11.png?raw=true)
