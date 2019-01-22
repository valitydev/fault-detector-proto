include "base.thrift"

namespace java com.rbkmoney.damsel.fault_detector
namespace erlang fault_detector

typedef base.ID ServiceId
typedef base.ID RequestId

enum Reliability {
    BAD
    NEUTRAL
    GOOD
}

struct AvailabilityResponse {
    1: required ServiceId service_id
    2: required double timeout_rate
    3: required double success_rate
    4: required double conversion_rate // когда-нибудь появится
    5: required Reliability reliability // если хотим положиться на рассчёты сервиса
}

union Operation {
    1: Start start
    2: Finish finish
    3: Error error
}

struct Start {
    1: required base.Timestamp time_start
}

struct Finish {
    1: required base.Timestamp time_spent
}

// Какие типы ошибок хотим видеть вообще?
struct Error {
    1: required base.Timestamp time_spent
}

// Устанавливаем какие-то из значений для disable/enable сервиса, полезная ручка
struct SetRequest {
    1: required SetType set_type
    2: required double value // Значение от 0 до 1
}

enum SetType {
    TIMEOUT
    SUCCESS
    CONVERSION
    ALL
}

service FaultDetector {

    /**
     * Проверка доступности сервисов
     **/
    list<AvailabilityResponse> CheckAvailability(1: list<ServiceId> services)

    /**
     * Регистрация процесса операции
     **/
    void RegisterOperation(1: ServiceId service_id, 2: RequestId request_id, 3: Operation operation)

    /**
     * Сброс/Установка статистики сервиса.
     * Может потенциально пригодиться для более умных сервисов, которые вкурсе "проблем"
     **/
    void SetServiceStatistics(1: ServiceId service_id, 2: SetRequest set_request)

}