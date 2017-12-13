package org.bathml.parking;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.Arrays;

import static java.util.Arrays.asList;

@RestController
public class ParkingController {

    @PostMapping("/parking")
    public ParkingResponse post(final @RequestBody ParkingRequest req) {
        //Return dummy data for now.
        return makeDummyResponse();
    }

    private ParkingResponse makeDummyResponse() {
        final ParkingResponse res = new ParkingResponse();
        res.setCarparkDetails(makeDummyCarparkDetails());
        res.setPrediction(makeDummyPrediction());
        return res;
    }

    private Prediction makeDummyPrediction() {
        final Prediction prediction = new Prediction();
        prediction.setBucket(3);
        prediction.setProbabilities(asList(
                9, 10, 5, 10, 3, 20, 5, 19, 5, 9, 5
        ));
        return prediction;
    }

    private CarparkDetails makeDummyCarparkDetails() {
        final CarparkDetails details = new CarparkDetails();
        details.setCapacity(128);
        details.setPostCode("BA11AB");
        return details;
    }
}
