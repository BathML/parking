package org.bathml.parking;

public class Weather {

    private Boolean rain;
    private Boolean fog;
    private Boolean snow;
    private Integer percipitation;

    public Boolean getRain() {
        return rain;
    }

    public void setRain(Boolean rain) {
        this.rain = rain;
    }
    public Boolean getFog() {
        return fog;
    }

    public void setFog(Boolean fog) {
        this.fog = fog;
    }

    public Boolean getSnow() {
        return snow;
    }

    public void setSnow(Boolean snow) {
        this.snow = snow;
    }

    public Integer getPercipitation() {
        return percipitation;
    }

    public void setPercipitation(Integer percipitation) {
        this.percipitation = percipitation;
    }
}
