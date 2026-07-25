/* 
  Visitor Counter API Fetch
  Connects to AWS API Gateway -> Lambda -> DynamoDB to fetch and increment page views.
*/

const API_URL = "https://j4r2whrdcd.execute-api.eu-central-1.amazonaws.com/visitors";
const counterElement = document.getElementById("visitor-count");

async function updateCounter() {
  if (!counterElement) return;

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 8000);

  try {
    const response = await fetch(API_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      signal: controller.signal
    });

    if (!response.ok) {
      throw new Error(`API request failed with status: ${response.status}`);
    }

    const data = await response.json();
    const count = Number(data.count || data.visitorCount || data.views);

    if (!Number.isFinite(count)) {
      throw new Error("API returned an invalid numeric value");
    }

    
    counterElement.textContent = count.toLocaleString();

  } catch (error) {
    console.warn("Visitor counter fallback triggered:", error.message);
    counterElement.textContent = "Offline";
  } finally {
    clearTimeout(timeoutId);
  }
}

updateCounter();