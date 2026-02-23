# Phase 7: Data Sharing

This phase enables secure, scalable sharing of de-identified clinical data with up to 1000 different hospitals using Snowflake Secure Data Sharing.
Snowflake Secure Data Sharing is a powerful feature that enables live, governed, and cost-effective data sharing between accounts without copying or moving data

## Key Steps
- Create a secure share for the Gold table.
- Grant SELECT access to the share.
- Add up to 1000 hospital accounts as **consumers.**
- Ensure only de-identified, compliant data is shared.

## Usage
1. Edit `phase7_data_sharing_setup.sql` to include the list of hospital accounts.
2. Run the script in your Snowflake environment.
3. Each hospital will receive access to the shared data via their Snowflake account.

## Notes
- Use automation (Python, Terraform, etc.) to generate and manage large account lists.
- Ensure compliance and auditability for all shared data.

Note:
# How does Secure Data Sharing work?
With Secure Data Sharing, no actual data is copied or transferred between accounts. All sharing uses **Snowflake’s services layer and metadata store.** Shared data does not take up any storage in a consumer account and therefore does not contribute to the consumer’s monthly data storage charges. The only charges to consumers are for the compute resources (i.e. virtual warehouses) used to query the imported data.

****Data providers add Snowflake objects** (databases, schemas, tables, secure views, etc.) to a share using either or both of the following options:

**Option 1:** Grant privileges on objects to a share via a database role.
**Option 2:** Grant privileges on objects directly to a share.
You choose which accounts can consume data from the share by adding the accounts to the share.

![alt text](image.png)

**Snowflake accounts**
Data sharing is **only supported between Snowflake accounts**. As a data provider, you might want to share data with a consumer who does not already have a Snowflake account or is not ready to become a licensed Snowflake customer.

**No Snowflake accounts**
**Reader Account: Third Party**
To facilitate sharing data with these consumers, you can create reader accounts. Reader accounts (formerly known as “read-only accounts”) provide a quick, easy, and cost-effective way to share data without requiring the consumer to become a Snowflake customer.

Each reader account belongs to the provider account that created it. As a provider, you use shares to share databases with reader accounts; however, a reader account can only consume data from the provider account that created it. Refer to the following diagram:
![alt text](image-1.png)

Note:
## What is a **Share** in Snowflake Inc.?

A Share is NOT an account.

A **Share** is a Snowflake object that lets you give another Snowflake account **live, read-only access** to your data — **without copying the data**.

Think of it like:

> 📺 Netflix account = Snowflake Account
> 🎬 Shared movie access = Snowflake Share

You don’t send the movie file. You just allow them to stream it.

---

# 🔎 Is a Share an Account?

❌ No — it is **not** an account.
✔ It is a **data access container** that connects accounts.

There are **two separate things**:

| Object            | What It Is                           |
| ----------------- | ------------------------------------ |
| Snowflake Account | A company’s Snowflake environment    |
| Share             | A permission bridge between accounts |

---

# 🏥 Real Healthcare Example

Imagine:

* Your company → `MAIN_HEALTHCARE_ACCOUNT`
* Hospital → `HOSPITAL1_ACCOUNT`

You want Hospital 1 to see only their patient data.

---

## Step 1: Create a Share

Inside your account:

```sql
CREATE SHARE HOSPITAL_DATA_SHARE;
```

This creates an **empty sharing container**.

---

## Step 2: Put Data Inside the Share

```sql
GRANT USAGE ON DATABASE HEALTHCARE_DB TO SHARE HOSPITAL_DATA_SHARE;

GRANT USAGE ON SCHEMA HEALTHCARE_DB.SHARING TO SHARE HOSPITAL_DATA_SHARE;

GRANT SELECT ON VIEW HEALTHCARE_DB.SHARING.HOSPITAL_DATA_V
TO SHARE HOSPITAL_DATA_SHARE;
```

Now the share contains access to that view.

---

## Step 3: Connect Hospital Account

```sql
ALTER SHARE HOSPITAL_DATA_SHARE 
ADD ACCOUNT = HOSPITAL1_ACCOUNT;
```

Now Hospital1 can access it.

---

## Step 4: What Hospital Does

Inside Hospital’s Snowflake account:

```sql
CREATE DATABASE SHARED_DB
FROM SHARE MAIN_HEALTHCARE_ACCOUNT.HOSPITAL_DATA_SHARE;
```

Now they can query:

```sql
SELECT * FROM SHARED_DB.SHARING.HOSPITAL_DATA_V;
```

They are reading your live data — but it stays in your account.

---

# 🧠 What a Share Actually Does

When you create a share:

* ✔ No data is copied
* ✔ No files are transferred
* ✔ No storage duplication
* ✔ They query your data in real time
* ✔ They cannot modify your data

It is **read-only by design**.

---

# 🏗 Visual Example

```
Your Account
-----------------------
HEALTHCARE_DB
     │
     ▼
[ SHARE ]
     │
     ▼
Hospital Account
```

The data never leaves your account.

---

# 🔐 Why This Is Powerful

Traditional method:

* Export CSV
* Send file
* Upload to hospital
* Duplicate storage
* Sync problems

Snowflake Share:

* Real-time
* No duplication
* Secure
* Governed
* Auditable

---

# 💡 Simple Business Example

Let’s say you are Amazon (example):

You want a supplier to see only their sales numbers.

Instead of emailing reports:

* Create Share
* Add supplier account
* They query live data

Done.

---

# 🆚 Share vs Reader Account

| Feature                            | Share | Reader Account |
| ---------------------------------- | ----- | -------------- |
| Needs their own Snowflake account? | Yes   | No             |
| Data copied?                       | No    | No             |
| Managed by you?                    | No    | Yes            |

Reader accounts are also created inside Snowflake Inc. but managed by you.

---

# 🎯 Final Simple Definition

A **Share** is:

> A secure, read-only connection that allows one Snowflake account to access selected data in another Snowflake account without copying it.

