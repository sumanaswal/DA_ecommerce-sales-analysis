# Olist E-Commerce Analytics Dashboard

End-to-End Data Analytics Portfolio Project  
Driving Business Decisions through Data

![Power BI Dashboard](docs/Dashboard_Screenshots/Page1_Executive.png)

## 📋 Project Overview

This project demonstrates a complete end-to-end data analytics solution for Olist, Brazil's largest e-commerce marketplace. I analyzed ~100,000 orders (2016–2018) to uncover insights on revenue, customer behavior, delivery performance, and product strategy.

### Key Business Challenge Addressed:
- 97% of customers are one-time buyers → Major retention issue
- Delivery delays impacting customer satisfaction
- Need for clear category and seller performance visibility

---

## 🛠️ Tech Stack

- Database: PostgreSQL
- Data Ingestion: Python (Pandas + SQLAlchemy)
- Data Cleaning & Transformation: Advanced SQL (CTEs, Window Functions)
- Data Modeling: Star Schema Design
- Analytics: RFM Segmentation, Cohort Analysis
- Visualization: Power BI Desktop + DAX
- Version Control: Git & GitHub

---

## 📊 Key Insights

- Customer Retention: Only ~3% of customers make repeat purchases
- Revenue: Total Revenue of R$ XX.X Million across 98,666 orders
- Delivery Performance: On-time delivery rate of XX.X%
- Top Performing Category: `health_beauty` and `watches_gifts` dominate revenue
- Geographical Insight: São Paulo and Rio de Janeiro contribute highest revenue but face delivery challenges

---

## 🎯 Actionable Recommendations

1. Launch a loyalty program targeting one-time buyers to improve retention
2. Focus operational improvements on high-volume states (SP, RJ, MG)
3. Review seller onboarding and performance monitoring system
4. Optimize pricing strategy for categories with low review scores
5. Implement targeted marketing for high-value customer segments (Champions & Loyal)

---

## 🏗️ Architecture

- Raw Layer → Cleaned Layer → Analytics Views → Star Schema → Power BI
- Proper handling of Order vs Item grain mismatch
- RFM Customer Segmentation implemented
- Optimized relationships and DAX measures

![Star Schema](docs/ERD.png)

---

## 📁 Repository Structure

Olist-Ecommerce-Analytics/
├── data/                     # Raw dataset (gitignore)
├── sql/                      # All SQL scripts
├── src/                      # Python loading scripts
├── powerbi/                  # .pbix file + screenshots
├── docs/
│   ├── ERD.png
│   └── Dashboard_Screenshots/
├── notebooks/                # EDA Jupyter Notebook
└── README.md


---

## 🚀 How to Run

1. Clone the repository
2. Restore PostgreSQL database using SQL scripts in `/sql` folder
3. Open `Olist_Ecommerce_Dashboard.pbix` in Power BI
4. Update database connection if needed

---

## 📈 Dashboard Pages

1. Executive Overview – High-level KPIs and trends
2. Sales & Product Analysis – Category and product performance
3. Customer Insights & RFM – Segmentation and retention
4. Operations & Logistics – Delivery and seller performance
5. Insights & Recommendations – Business summary


---

## 🎓 Learnings & Future Enhancements

- Advanced data modeling and grain handling
- Performance optimization in Power BI
- Translating data into actionable business recommendations

Future Work:
- Demand forecasting using Python/ML
- NLP sentiment analysis on customer reviews
- Customer Lifetime Value (CLV) modeling

---

## 👤 Author

Suman Aswal 
Aspiring Data Analyst / BI Developer  
sumanaswal818@gmail.com

---

Feel free to reach out if you want to discuss the project!
