from devops_health_checker import app


def test_home_endpoint():
    client = app.test_client()

    response = client.get("/")

    assert response.status_code == 200

    data = response.get_json()

    assert data["service"] == "devops-health-checker"
    assert data["status"] == "BROKEN"
