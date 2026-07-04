import http from "k6/http";
import { check, sleep } from "k6";
import { Rate, Trend } from "k6/metrics";

export const options = {
  scenarios: {
    smoke: {
      executor: "ramping-vus",
      stages: [
        { duration: __ENV.RAMP_UP || "30s", target: Number(__ENV.VUS || 20) },
        { duration: __ENV.DURATION || "2m", target: Number(__ENV.VUS || 20) },
        { duration: __ENV.RAMP_DOWN || "30s", target: 0 }
      ]
    }
  },
  thresholds: {
    http_req_failed: ["rate<0.02"],
    http_req_duration: ["p(95)<1000", "p(99)<2500"]
  }
};

const baseUrl = (__ENV.BASE_URL || "http://localhost:5058").replace(/\/$/, "");
const token = __ENV.TOKEN || "";
const endpoint = __ENV.ENDPOINT || "/api/Empresa/GetAllPaginado";
const method = (__ENV.METHOD || "POST").toUpperCase();
const thinkTimeSeconds = Number(__ENV.THINK_TIME || 1);
const payload = __ENV.BODY || JSON.stringify({
  page: 1,
  pageSize: Number(__ENV.PAGE_SIZE || 20),
  filtro: "",
  sortLabel: "",
  sortDirection: "Ascending",
  searchString: "",
  additionalFilters: {}
});

const latency = new Trend("egestion_endpoint_latency", true);
const successRate = new Rate("egestion_success");

export default function () {
  const params = {
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json"
    }
  };

  if (token) {
    params.headers.Authorization = `Bearer ${token}`;
  }

  const url = `${baseUrl}${endpoint.startsWith("/") ? endpoint : `/${endpoint}`}`;
  const response = method === "GET"
    ? http.get(url, params)
    : http.request(method, url, payload, params);

  const ok = check(response, {
    "status 2xx": (r) => r.status >= 200 && r.status < 300,
    "body present": (r) => r.body && r.body.length > 0
  });

  latency.add(response.timings.duration);
  successRate.add(ok);
  sleep(thinkTimeSeconds);
}
