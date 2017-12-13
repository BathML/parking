package org.bathml.parking;

public class ParkingResponse {
    private Prediction prediction;
    private CarparkDetails carparkDetails;

    public Prediction getPrediction() {
        return prediction;
    }

    public void setPrediction(Prediction prediction) {
        this.prediction = prediction;
    }

    public CarparkDetails getCarparkDetails() {
        return carparkDetails;
    }

    public void setCarparkDetails(CarparkDetails carparkDetails) {
        this.carparkDetails = carparkDetails;
    }
}
