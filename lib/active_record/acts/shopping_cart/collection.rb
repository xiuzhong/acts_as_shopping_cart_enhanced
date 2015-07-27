module ActiveRecord
  module Acts
    module ShoppingCart
      module Collection
        #
        # Adds a product to the cart
        # cumulative = true, update quantity of existing item or create new one if no existing
        # cumulative = false, create a new one in any cases
        def add(object, price, quantity = 1, cumulative = true)
          if cumulative && (cart_item = item_for(object))
            cart_item.quantity += quantity
            cart_item.save
            cart_item
          else
            shopping_cart_items.create(item: object, price: price, quantity: quantity)
          end          
        end

        #
        # Deletes all shopping_cart_items in the shopping_cart
        #
        def clear
          shopping_cart_items.clear
        end

        #
        # Returns true when the cart is empty
        #
        def empty?
          shopping_cart_items.empty?
        end

        #
        # Remove an item from the cart
        #
        def remove(object, quantity = 1)
          if cart_item = item_for(object)
            if cart_item.quantity <= quantity
              cart_item.delete
            else
              cart_item.quantity = (cart_item.quantity - quantity)
              cart_item.save
            end
          end
        end

        #
        # Returns the subtotal by summing the price times quantity for all the
        # items in the cart
        #
        def subtotal
          shopping_cart_items.inject(Money.new(0, self.supplier.shop_currency)) { |sum, item| sum += (item.price * item.quantity) }
        end

        def shipping_cost
          Money.new(0, self.supplier.shop_currency)
        end

        def taxes
          subtotal * self.tax_pct * 0.01
        end

        def tax_pct
          8.25
        end

        #
        # Returns the total by summing the subtotal, taxes and shipping_cost
        #
        def total
          self.subtotal + self.taxes + self.shipping_cost
        end

        #
        # Return the number of unique items in the cart
        #
        def total_unique_items
          shopping_cart_items.inject(0) { |sum, item| sum += item.quantity }
        end

        def cart_items
          warn "ShoppingCart#cart_items WILL BE DEPRECATED IN LATER VERSIONS OF acts_as_shopping_cart, please use ShoppingCart#shopping_cart_items instead"
          self.shopping_cart_items
        end
      end
    end
  end
end
