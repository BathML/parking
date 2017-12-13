package org.bathml.parking;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ParkingController {

    @PostMapping("/parking")
    public ParkingResponse post(final @RequestBody ParkingRequest req) {
        //Return dummy data for now.
        return null;
    }
}
