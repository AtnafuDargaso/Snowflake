### Phase 4: Security & Presentation (The "Secure View")

You cannot let doctors see *all* patients; they should only see *their* patients.

8. **Row-Level Security (RLS):** Create an **Entitlement Table** that maps `DOCTOR_ID` to `PATIENT_ID`.
9. **The Secure View:** Create a **SECURE VIEW** that joins the Gold table with the Entitlement table using the `CURRENT_ROLE()` or `CURRENT_USER()` function.
* *Why a Secure View?* It prevents unauthorized users from seeing the underlying metadata or query plan, protecting PII (Personally Identifiable Information).
