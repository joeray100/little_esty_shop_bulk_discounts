Merchant.destroy_all
Discount.destroy_all
Item.destroy_all
Customer.destroy_all
Invoice.destroy_all
InvoiceItem.destroy_all
Transaction.destroy_all


merchant1 = Merchant.create!(name: 'Merchant 1')
discount1 = merchant1.discounts.create!(name: "discount 1", discount_percentage: 10, quantity_threshold: 10)
discount2 = merchant1.discounts.create!(name: "discount 2", discount_percentage: 20, quantity_threshold: 10)
discount3 = merchant1.discounts.create!(name: "discount 3", discount_percentage: 30, quantity_threshold: 20)
discount4 = merchant1.discounts.create!(name: "discount 4", discount_percentage: 50, quantity_threshold: 30)
item1 = merchant1.items.create!(name: "Shampoo", description: "This washes your hair", unit_price: 20)
item2 = merchant1.items.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 10)
item3 = merchant1.items.create!(name: "Brush", description: "This takes out tangles", unit_price: 15)
#  merchant 2 has an item but no discounts
merchant2 = Merchant.create!(name: 'Merchant 2')
item4 = merchant2.items.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 5)

customer1 = Customer.create!(first_name: 'Joey', last_name: "'Smells like spicy pickles' McMuffinPants")
customer2 = Customer.create!(first_name: 'Sarah', last_name: "'Ankle Breaker' Jones")
invoice1 = customer1.invoices.create!(status: 2, created_at: "2012-03-27 14:54:09") # TR = 150
invoice2 = customer1.invoices.create!(status: 2, created_at: "2012-04-27 14:54:09") # TR = 375 / TDR = 315
invoice3 = customer1.invoices.create!(status: 2, created_at: "2012-05-27 14:54:09") # TR = 350 / TDR = 260
invoice4 = customer2.invoices.create!(status: 2, created_at: "2012-06-27 14:54:09") # TR = 300 / TDR = 240
invoice5 = customer2.invoices.create!(status: 2, created_at: "2012-07-27 14:54:09") # TR = 300 / TDR = 210

# ---------------------------------------EXAMPLE 1---------------------------------------------------------------------
ii_1 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item1.id, quantity: 5, unit_price: 20, status: 2) # no discount
ii_2 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item2.id, quantity: 5, unit_price: 10, status: 2) # no discount
# ----------------------------------------EXAMPLE 2--------------------------------------------------------------------
ii_3 = InvoiceItem.create!(invoice_id: invoice2.id, item_id: item3.id, quantity: 5, unit_price: 15, status: 2) # no discount
ii_4 = InvoiceItem.create!(invoice_id: invoice2.id, item_id: item1.id, quantity: 15, unit_price: 20, status: 2) # 20% discount
# --------------------------------------EXAMPLE 3----------------------------------------------------------------------
ii_5 = InvoiceItem.create!(invoice_id: invoice3.id, item_id: item3.id, quantity: 10, unit_price: 15, status: 2) # 20% discount
ii_6 = InvoiceItem.create!(invoice_id: invoice3.id, item_id: item2.id, quantity: 20, unit_price: 10, status: 2) # 30% discount
# ---------------------------------------EXAMPLE 4---------------------------------------------------------------------
ii_7 = InvoiceItem.create!(invoice_id: invoice4.id, item_id: item2.id, quantity: 10, unit_price: 10, status: 2) # 20% discount
ii_8 = InvoiceItem.create!(invoice_id: invoice4.id, item_id: item1.id, quantity: 10, unit_price: 20, status: 2) # 20% discount
# ---------------------------------------EXAMPLE 5---------------------------------------------------------------------
ii_9 = InvoiceItem.create!(invoice_id: invoice5.id, item_id: item3.id, quantity: 20, unit_price: 15, status: 2) # 30% discount
# ii 10 should not be on invoice 5 for merchant 1 and same for merchant 2
ii_10 = InvoiceItem.create!(invoice_id: invoice5.id, item_id: item4.id, quantity: 15, unit_price: 5, status: 2) # no discount, merchant2 has none


transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: invoice1.id)
transaction2 = Transaction.create!(credit_card_number: 230948, result: 1, invoice_id: invoice2.id)
transaction3 = Transaction.create!(credit_card_number: 655849, result: 1, invoice_id: invoice3.id)
