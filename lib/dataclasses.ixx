module;

#include <string>
#include <chrono>
#include <optional>
#include <vector>

export module dataclasses;

export struct SwimmingEvent;

export struct SwimmingAthlete {
    std::string first_name;
    std::string last_name;
    uint16_t athlete_id;
    std::vector<SwimmingEvent> events;
};

export struct SwimmingEvent {
    std::string event_name;
    std::string finals;
    std::string relay;
    std::chrono::year_month_day event_date;
    std::optional<int> swimmer_number;
};
