package org.example;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class ExampleController {

    @GetMapping
    public String get() {
        return "Hello World!";
    }

    @PostMapping
    public void post(@RequestBody ExampleRequest request) {
        System.out.println(request.example());
    }

    @PostMapping(consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE)
    public void postHelp(ExampleRequest request) {
        System.out.println(request.example());
    }
}
