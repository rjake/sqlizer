with
    customer_orders as (
        select
            customer_id,
            min(order_date) as first_order_date,
            max(order_date) as most_recent_order_date,
            count(order_id) as number_of_orders
        from
            data_lake.jaffle_shop.orders
        group by 1
    )

select
    cs.customer_id,
    cs.first_name,
    cs.last_name,
    ord.first_order_date,
    ord.most_recent_order_date,
    coalesce(ord.number_of_orders, 0) as number_of_orders

from
  data_lake.jaffle_shop.customers  cs
  left join customer_orders ord on cs.customer_id = ord.customer_id



with
orders as (
    select
        order_id,
        order_cancelled,
        event_id,
        event_name,
        event_start,
        event_end,
        order_items,
        tax_amount,
        tickets_checked_in,
        tickets_purchased,
        total_paid,
        charge_id,
        transaction_type,
        order_date
    from
        data_lake.ticket_tailor.orders
),

charges as (

    select
        charge_id,
        captured,
        created,
        currency,
        description,
        failure_code,
        failure_message,
        fraud_details,
        livemode,
        object,
        paid,
        refunded,
        status
    from
        data_mart.stripe_systems.charges
),

refunds as (

    select
        refund_id,
        charge_id,
        currency,
        created,
        status
    from
        data_mart.stripe_systems.refunds
)

select
    orders.order_id,
    charges.charge_id,
    refunds.refund_id
from orders
left join charges using (charge_id)
left join refunds using (charge_id)
