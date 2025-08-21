from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from mangum import Mangum
import os

# Import API routers for different versions
from src.api.v0.api import router as api_v0_router

env = os.getenv("environment", "dev")

# Set root path to the environment variable
# This is to match the API Gateway configuration
app = FastAPI(root_path=f"/{env}")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins, adjust as needed
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods, adjust as needed
    allow_headers=["*"],  # Allows all headers, adjust as needed
)

# Add different API routers here for different versions
# This allows us to add or remove API versions easily
app.include_router(api_v0_router, prefix="/api/v0", tags=["v0"])

# This bit is for Lambda integration
# This wraps the FastAPI app into a handler method that can be used by AWS Lambda
handler = Mangum(app)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
