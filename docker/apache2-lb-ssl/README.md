This Dockerfile and related files can be used to build an Apache2 web server image with common modules for rewrite, reverse-proxy and load-balancing installed, along with SSL proxy, redirect and passthrough support.

There are several testcases in the `testcases` directory to try out the various Virtual Host configurations to support these features.

1. [Apache 2 web server default configuration] (https://github.com/techyugadi/kubestash/tree/master/docker/apache2-lb-ssl/testcases/apacheconf/defaultconf)

2. [ Reverse Proxy Configuration ] (https://github.com/techyugadi/kubestash/tree/master/docker/apache2-lb-ssl/testcases/apacheconf/revproxy)

3. [ Enabling both HTTP and HTTPS end-points ] (https://github.com/techyugadi/kubestash/tree/master/docker/apache2-lb-ssl/testcases/apacheconf/sslsupport)

4. [ Redirecting HTTP requests to HTTPS end-point ] (https://github.com/techyugadi/kubestash/tree/master/docker/apache2-lb-ssl/testcases/apacheconf/sslenforce)

5. [ Pass-through HTTP requests (tunneling) to HTTPS back-end ] (https://github.com/techyugadi/kubestash/tree/master/docker/apache2-lb-ssl/testcases/apacheconf/sslpassthru)

6. [ Simple load-balancer using mod_proxy_balancer ] (https://github.com/techyugadi/kubestash/tree/master/docker/apache2-lb-ssl/testcases/apacheconf/proxylb)

7. [ Load-balancer with Session stickiness using mod_proxy_balancer ] (https://github.com/techyugadi/kubestash/tree/master/docker/apache2-lb-ssl/testcases/apacheconf/proxylbsticky)

8. [ Load-balancer with Session stickiness and SSL redirect ] (https://github.com/techyugadi/kubestash/tree/master/docker/apache2-lb-ssl/testcases/apacheconf/proxylbstickyssl)

9. [ URL Rewrite Rules ] (https://github.com/techyugadi/kubestash/tree/master/docker/apache2-lb-ssl/testcases/apacheconf/rewrite)

10. [ AJP Connector (for Tomcat) ] (https://github.com/techyugadi/kubestash/tree/master/docker/apache2-lb-ssl/testcases/apacheconf/ajp)

11. [ Tomcat Connector using mod_jk ] (https://github.com/techyugadi/kubestash/tree/master/docker/apache2-lb-ssl/testcases/apacheconf/jk)

12. [ Load-balancing using mod_jk (with Tomcat) ] (https://github.com/techyugadi/kubestash/tree/master/docker/apache2-lb-ssl/testcases/apacheconf/jklb)

13. [ Load-balancing with session stickiness using mod_jk (with Tomcat) ] (https://github.com/techyugadi/kubestash/tree/master/docker/apache2-lb-ssl/testcases/apacheconf/jklbsticky)

14. [ Load-balancing with session stickiness and session failover (persistence) ] (https://github.com/techyugadi/kubestash/tree/master/docker/apache2-lb-ssl/testcases/apacheconf/jettysesspers)

Java Web applications to test thes configurations (for Jetty or Tomcat) are also included in the directory `testcases/apps`). 
