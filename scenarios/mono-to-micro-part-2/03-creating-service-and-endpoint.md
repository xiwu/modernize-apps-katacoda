
Now you are going to create a service class. Later on the service class will be the one that controls the interaction with the inventory service, but for now it's basically just a wrapper of the repository class. 

``src/main/java/com/redhat/coolstore/service/CatalogService.java``{{open}}
<pre class="file" data-filename="src/main/java/com/redhat/coolstore/service/CatalogService.java" data-target="replace">
package com.redhat.coolstore.service;

import com.redhat.coolstore.model.Inventory;
import com.redhat.coolstore.model.Product;
import feign.hystrix.FallbackFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.netflix.feign.FeignClient;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CatalogService {

    @Autowired
    private ProductRepository repository;

    //TODO: Autowire Inventory Client

    public Product read(String id) {
        Product product = repository.findById(id);
        //TODO: Update the quantity for the product by calling the Inventory service
        return product;
    }

    public List<Product> readAll() {
        List<Product> productList = repository.readAll();
        //TODO: Update the quantity for the products by calling the Inventory service
        return productList; 
    }

    //TODO: Add Callback Factory Component


}
</pre>

As you can see there is a number of **TODO** in the code, and later we will use these placeholders to add logic for calling the Inventory Client to get the quantity. However for the moment we will ignore these placeholders. 

Let's again first start by creating a test case for our endpoint


``src/test/java/com/redhat/coolstore/service/CatalogEndpointTest.java``{{open}}


<pre class="file" data-filename="src/test/java/com/redhat/coolstore/service/CatalogEndpointTest.java" data-target="replace">
package com.redhat.coolstore.service;

import com.redhat.coolstore.model.Inventory;
import com.redhat.coolstore.model.Product;
import io.specto.hoverfly.junit.rule.HoverflyRule;
import org.junit.ClassRule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.junit4.SpringRunner;

import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

import static io.specto.hoverfly.junit.dsl.HttpBodyConverter.json;
import static io.specto.hoverfly.junit.dsl.ResponseCreators.success;
import static io.specto.hoverfly.junit.dsl.matchers.HoverflyMatchers.startsWith;
import static org.assertj.core.api.Assertions.assertThat;
import static io.specto.hoverfly.junit.core.SimulationSource.dsl;
import static io.specto.hoverfly.junit.dsl.HoverflyDsl.service;

@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class CatalogEndpointTest {

    @Autowired
    private TestRestTemplate restTemplate;

    //TODO: Add ClassRule for HoverFly Inventory simulation

    @Test
    public void test_retriving_one_proudct() {
        ResponseEntity<Product> response
                = restTemplate.getForEntity("/services/product/329199", Product.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody())
                .returns("329199",Product::getItemId)
                .returns("Forge Laptop Sticker",Product::getName)
                //TODO: Add check for Quantity
                .returns(8.50,Product::getPrice);
    }


    @Test
    public void check_that_endpoint_returns_a_correct_list() {

        ResponseEntity<List<Product>> rateResponse =
                restTemplate.exchange("/services/products",
                        HttpMethod.GET, null, new ParameterizedTypeReference<List<Product>>() {
                        });

        List<Product> productList = rateResponse.getBody();
        assertThat(productList).isNotNull();
        assertThat(productList).isNotEmpty();
        List<String> names = productList.stream().map(Product::getName).collect(Collectors.toList());
        assertThat(names).contains("Red Fedora","Forge Laptop Sticker","Oculus Rift");

        Product fedora = productList.stream().filter( p -> p.getItemId().equals("329299")).findAny().get();
        assertThat(fedora)
                .returns("329299",Product::getItemId)
                .returns("Red Fedora", Product::getName)
                //TODO: Add check for Quantity
                .returns(34.99,Product::getPrice);
    }

}
</pre>

Implement the Catalog Service endpoints

``src/main/java/com/redhat/coolstore/service/CatalogEndpoint.java``{{open}}

<pre class="file" data-filename="src/main/java/com/redhat/coolstore/service/CatalogEndpoint.java" data-target="replace">
package com.redhat.coolstore.service;

import java.util.List;

import com.redhat.coolstore.model.Product;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/services")
public class CatalogEndpoint {

    @Autowired
    private CatalogService catalogService;

    @ResponseBody
    @GetMapping("/products")
    public ResponseEntity<List<Product>> readAll() {
        return new ResponseEntity<List<Product>>(catalogService.readAll(),HttpStatus.OK);
    }

    @ResponseBody
    @GetMapping("/product/{id}")
    public ResponseEntity<Product> read(@PathVariable("id") String id) {
        return new ResponseEntity<Product>(catalogService.read(id),HttpStatus.OK);
    }

}
</pre>


Run the test and verify that it works

``mvn verify``{{execute}}

Start the service

``mvn spring-boot:run``{{execute}}

Wait for the application to start

``curl http://localhost:8080/services/products``{{execute T2}}




