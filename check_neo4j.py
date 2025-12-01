from neo4j import GraphDatabase

uri = "bolt://localhost:7687"
user = "neo4j"
passwords = ["clinixai_neo4j_password", "neo4j", "password", "admin"]

for p in passwords:
    print(f"Trying password: {p}")
    try:
        driver = GraphDatabase.driver(uri, auth=(user, p))
        driver.verify_connectivity()
        print(f"✅ Success with password: {p}")
        driver.close()
        break
    except Exception as e:
        print(f"❌ Failed: {e}")
