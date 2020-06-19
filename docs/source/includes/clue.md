<h1 id="api-service-countries">Countries</h1>

<p>This section contains all the endpoints of the countries service offered by the Flywire API service. This service is maintained by the <b>Platform CORE team</b><p> If you detect that some documented endpoint needs to be updated, you could create a ticket in our JIRA project.<p> <b>NOTES:</b> <p>The <b>locale</b> query param is available for every endpoint, in this way if a translation exists for a certain message, it will be returned in that specific language, if not, it will be returned in the default one.</p>

Base URLs:

* <a href="https://api.flywire.com/">https://api.flywire.com/</a>
* <a href="https://api.demo.flywire.com/">https://api.demo.flywire.com/</a>

## Returns the countries from where an order can be created in Flywire

> Code samples

```shell
# You can also use wget
curl -X GET https://api.flywire.com/v3/countries \
  -H 'Accept: application/json'

```

```ruby
require 'rest-client'
require 'json'

headers = {
  'Accept' => 'application/json'
}

result = RestClient.get 'https://api.flywire.com/v3/countries',
  params: {
  }, headers: headers

p JSON.parse(result)

```

```java
URL obj = new URL("https://api.flywire.com/v3/countries");
HttpURLConnection con = (HttpURLConnection) obj.openConnection();
con.setRequestMethod("GET");
int responseCode = con.getResponseCode();
BufferedReader in = new BufferedReader(
    new InputStreamReader(con.getInputStream()));
String inputLine;
StringBuffer response = new StringBuffer();
while ((inputLine = in.readLine()) != null) {
    response.append(inputLine);
}
in.close();
System.out.println(response.toString());

```

```http
GET https://api.flywire.com/v3/countries HTTP/1.1
Host: api.flywire.com
Accept: application/json

```

`GET /v3/countries`

Returns the countries from where an order can be created in Flywire

> Example responses

> 200 Response

```json
[
  {
    "code": "ES",
    "name": "Spain"
  },
  {
    "code": "GB",
    "name": "United Kingdom"
  },
  {
    "code": "SG",
    "name": "Singapore"
  }
]
```

<h3 id="returns-the-countries-from-where-an-order-can-be-created-in-flywire-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|All the countries have been obtained|[ArrayOfCountries](#schemaarrayofcountries)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|None|