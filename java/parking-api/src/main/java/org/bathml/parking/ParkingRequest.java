package org.bathml.parking;

public class ParkingRequest {
    private String carpark;
    private Float timeOfDay;
    private Integer weekDay;
    private Integer weekNumber;
    private Boolean rugby;
    private Boolean rugbyHomeWin;
    private Integer cityEvents;
    private Weather weather;

    public String getCarpark() {
        return carpark;
    }

    public void setCarpark(String carpark) {
        this.carpark = carpark;
    }

    public Float getTimeOfDay() {
        return timeOfDay;
    }

    public void setTimeOfDay(Float timeOfDay) {
        this.timeOfDay = timeOfDay;
    }

    public Integer getWeekDay() {
        return weekDay;
    }

    public void setWeekDay(Integer weekDay) {
        this.weekDay = weekDay;
    }

    public Integer getWeekNumber() {
        return weekNumber;
    }

    public void setWeekNumber(Integer weekNumber) {
        this.weekNumber = weekNumber;
    }

    public Boolean getRugby() {
        return rugby;
    }

    public void setRugby(Boolean rugby) {
        this.rugby = rugby;
    }

    public Boolean getRugbyHomeWin() {
        return rugbyHomeWin;
    }

    public void setRugbyHomeWin(Boolean rugbyHomeWin) {
        this.rugbyHomeWin = rugbyHomeWin;
    }

    public Integer getCityEvents() {
        return cityEvents;
    }

    public void setCityEvents(Integer cityEvents) {
        this.cityEvents = cityEvents;
    }

    public Weather getWeather() {
        return weather;
    }

    public void setWeather(Weather weather) {
        this.weather = weather;
    }
}
