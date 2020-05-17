package com.example.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import java.util.Map;
import java.util.Random;
import javax.servlet.http.HttpSession;
import java.net.InetAddress;
import java.net.UnknownHostException;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/")
public class BaseController {

    private final AppService svc;

    @Autowired
    public BaseController(AppService svc) {
        this.svc = svc;
    }

    @RequestMapping(value = "/", method = RequestMethod.GET)
    public String welcome(ModelMap model, HttpSession session) {
        Integer n = (Integer) session.getAttribute("visitedCount");
        if (n == null) {
          session.setAttribute("visitedCount", 1);
          n = 1;
        } else {
          Integer count = (Integer) session.getAttribute("visitedCount");
          session.setAttribute("visitedCount", count + 1);
          n = count + 1;
        }
        InetAddress ip = null;
        try {
          ip = InetAddress.getLocalHost();
        } catch (UnknownHostException e) {
          e.printStackTrace();
        }
	String msg = "Hello ! Response from: " + ip + ". You landed here " + n + " times";
        model.addAttribute("message", msg);
        return "index";
    }

    @RequestMapping(value = "/{name}", method = RequestMethod.GET)
    public String welcomeName(@PathVariable String name, ModelMap model) {
        model.addAttribute("message", "Hello " + name);
        return "index";
    }

    @RequestMapping("/random")
    public String next(Map<String, Object> model, @RequestParam(required = false) String max) {
        int m = 100;
        if (max != null) {
          try {
            m = Integer.parseInt(max);
            if (m <= 0 || m >= 10000)
              m = 100;
          } catch (NumberFormatException nfe) {
          }
        }
        model.put("message", "Your lucky number is : " + 
			        (new Random()).nextInt(m));
        return "rand";
    }

}
