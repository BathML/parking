package org.bathml.parking;

import java.util.List;

public class Prediction {
    private Integer bucket;
    private List<Integer> probabilities;

    public Integer getBucket() {
        return bucket;
    }

    public void setBucket(Integer bucket) {
        this.bucket = bucket;
    }

    public List<Integer> getProbabilities() {
        return probabilities;
    }

    public void setProbabilities(List<Integer> probabilities) {
        this.probabilities = probabilities;
    }
}
