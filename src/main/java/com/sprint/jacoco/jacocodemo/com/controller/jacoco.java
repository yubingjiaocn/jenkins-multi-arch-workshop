package com.sprint.jacoco.jacocodemo.com.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import javax.servlet.http.HttpServletRequest;
import java.net.InetAddress;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

@RestController
public class jacoco {

    @RequestMapping(value = "/", produces = "application/json")
    @ResponseBody
    public Map<String, Object> hello(HttpServletRequest request, @RequestBody(required = false) String body) {
        Map<String, Object> response = new HashMap<>();
        try {
            // System Information
            InetAddress addr = InetAddress.getLocalHost();
            Runtime runtime = Runtime.getRuntime();

            Map<String, Object> systemInfo = new HashMap<>();
            systemInfo.put("hostname", addr.getHostName());
            systemInfo.put("ip", addr.getHostAddress());
            systemInfo.put("cpuArchitecture", System.getProperty("os.arch"));
            systemInfo.put("processorCount", runtime.availableProcessors());
            systemInfo.put("osName", System.getProperty("os.name"));
            systemInfo.put("osVersion", System.getProperty("os.version"));

            // Request Headers
            Map<String, String> headers = new HashMap<>();
            Enumeration<String> headerNames = request.getHeaderNames();
            while (headerNames.hasMoreElements()) {
                String headerName = headerNames.nextElement();
                headers.put(headerName, request.getHeader(headerName));
            }

            response.put("systemInfo", systemInfo);
            response.put("headers", headers);
            response.put("body", body != null ? body : "");

        } catch (Exception e) {
            response.put("error", e.getMessage());
        }

        return response;
    }

}
