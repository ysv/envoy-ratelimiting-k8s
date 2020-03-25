## Testing

#### Missing IP Address

Limited to zero requests per minute if `CF-Connecting-IP` Header is missing. 

**Configuration**
```yaml
- key: header_match
  value: cf-ip-missing
  rate_limit:
    unit: minute
    requests_per_unit: 0
```

**Testing**
```bash
for i in {1..5}; do
  curl -s -o /dev/null -w "$i->%{http_code}\n" http://cs.ysv.pp.ua/service/1
  sleep 0.5
done
```

#### Blacklisted IP Address (45.128.133.242)

Limited to zero requests per minute if `CF-Connecting-IP` ip is blacklisted. 

**Configuration**
```yaml
- key: cf-ip-address
  value: "45.128.133.242"
  rate_limit:
    unit: minute
    requests_per_unit: 0
```

**Testing**
```bash
export BLACKLISTED_IP="45.128.133.242"
for i in {1..5}; do
  curl -s -H "CF-Connecting-IP: $BLACKLISTED_IP" -o /dev/null -w "$i->%{http_code}\n" http://cs.ysv.pp.ua/service/1
  sleep 0.5
done
```

#### Common IP Address

- Limited to 5 requests per minute for all endpoints per `CF-Connecting-IP`. 
- Limited to 2 requests per minute for `/service/2` (sensitive endpoint) per `CF-Connecting-IP`.

**Configuration**
```yaml
- key: cf-ip-address
  rate_limit:
    unit: minute
    requests_per_unit: 5
  descriptors:
  - key: header_match
    value: sensetive-path
    rate_limit:
      unit: minute
      requests_per_unit: 2
```

**Testing**

- 10 requests to `service/1` (non-sensitive endpoint)

```bash
export COMMON_IP1="64.233.160.1"
for i in {1..10}; do
  curl -s -H "CF-Connecting-IP: $COMMON_IP1" -o /dev/null -w "$i->%{http_code}\n" http://cs.ysv.pp.ua/service/1
  sleep 0.5
done
```

- 5 requests to `service/2` (sensitive endpoint)

```bash
export COMMON_IP2="64.233.160.2"
for i in {1..5}; do
  curl -s -H "CF-Connecting-IP: $COMMON_IP2" -o /dev/null -w "$i->%{http_code}\n" http://cs.ysv.pp.ua/service/2
  sleep 0.5
done
```

- 2 requests to `service/2` (sensitive endpoint) and 5 more requests to `service/1` (non-sensitive endpoint)  

```bash
export COMMON_IP3="64.233.160.3"

echo "\n"
echo "service/2 (sensitive endpoint)"
for i in {1..2}; do
  curl -s -H "CF-Connecting-IP: $COMMON_IP3" -o /dev/null -w "$i->%{http_code}\n" http://cs.ysv.pp.ua/service/2
  sleep 0.5
done

echo "\n"
echo "service/1 (non-sensitive endpoint)"
for i in {1..5}; do
  curl -s -H "CF-Connecting-IP: $COMMON_IP3" -o /dev/null -w "$i->%{http_code}\n" http://cs.ysv.pp.ua/service/1
  sleep 0.5
done
```

#### Whitelisted IP Address (163.172.165.12)

- Limited to 10 requests per minute for all endpoints per `CF-Connecting-IP`. 
- Limited to 5 requests per minute for `/service/2` (sensitive endpoint) per `CF-Connecting-IP`.

**Configuration**
```yaml
- key: cf-ip-address
  value: "163.172.165.12"
  rate_limit:
    unit: minute
    requests_per_unit: 10
  descriptors:
  - key: header_match
    value: sensetive-path
    rate_limit:
      unit: minute
      requests_per_unit: 5
```

**Testing**

- 7 request to `service/2` (sensitive endpoint) and `service/1` (non-sensitive endpoint) one by one (14 request in total)

```bash
export WHITELISTED_IP="163.172.165.12"
for i in {1..7}; do
  curl -s -H "CF-Connecting-IP: $WHITELISTED_IP" -o /dev/null -w "$(($i*2-1)): service/2->%{http_code}\n" http://cs.ysv.pp.ua/service/2
  curl -s -H "CF-Connecting-IP: $WHITELISTED_IP" -o /dev/null -w "$(($i*2)): service/1->%{http_code}\n" http://cs.ysv.pp.ua/service/1  
  sleep 0.5
done
```
