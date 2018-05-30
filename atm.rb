require 'yaml'

class ATM
    def initialize path
        @config = YAML.load_file(ARGV.first || path)
        @choises = "Please Choose From the Following Options:
 1. Display Balance
 2. Withdraw
 3. Log Out"
    end
    
    public
    def authentificate

        begin
            puts "Please Enter Your Account Number:"
            print "> "
            account_no = STDIN.gets.chomp.to_i
            puts "Enter Your Password:"
            print "> "
            account_pass = STDIN.gets.chomp
            while !@config["accounts"].has_key?(account_no) || @config["accounts"][account_no]["password"] != account_pass do
                puts "\nERROR: ACCOUNT NUMBER AND PASSWORD DON'T MATCH\n\n"
                puts "Please Enter Your Account Number:"
                print "> "
                account_no = STDIN.gets.chomp.to_i
                puts "Enter Your Password:"
                print "> "
                account_pass = STDIN.gets.chomp
            end
            @currAccount = @config["accounts"][account_no]
            @banknotes = @config["banknotes"]
            
            puts "\nHello, #{@currAccount["name"]}!\n\n"
            workWithATM
        rescue => e
            puts e.message
        end

    end

    private
    def workWithATM

        begin
            puts @choises
            print "> "
            choise = STDIN.gets.chomp.to_i
            while !((1..3).include? choise) do
                puts "\nERROR: You choose incorrect Option\n\n"
                choise = STDIN.gets.chomp.to_i
                puts @choises
                print "> "
            end
            case choise
            when 1
                puts "\nYour Current Balance is ₴#{@currAccount["balance"]}\n\n"
                workWithATM
            when 2
                performWithdraw
                workWithATM
            when 3
                puts "\n#{@currAccount["name"]}, Thank You For Using Our ATM. Good-Bye!\n\n"
                @currAccount = nil
                @banknotes = nil
                authentificate
            end
        rescue => e
            puts e.message
        end
        
    end

    def performWithdraw

        account_balance = @currAccount["balance"]
    
        puts "Enter Amount You Wish to Withdraw:"
        print "> "
        while true do
            amount = STDIN.gets.chomp.to_i
            if amount > account_balance
                puts "\nERROR: INSUFFICIENT FUNDS!! PLEASE ENTER A DIFFERENT AMOUNT:"
                print "> "
                next
            elsif amount > atmCashAmount
                puts "\nERROR: THE MAXIMUM AMOUNT AVAILABLE IN THIS ATM IS ₴#{atmCashAmount}. PLEASE ENTER A DIFFERENT AMOUNT:"
                print "> "
            else
                if calcWithdraw amount
                    return
                end
            end
        end

    end

    def calcWithdraw amount

        tmp_banknotes = @banknotes.clone
    
        while !tmp_banknotes.empty? do
            sum = 0
            result_banknotes = {}
            @banknotes.each_key {|k| result_banknotes.store(k, 0)}
            tmp_banknotes.each do |k, v|
                v.times do |i|
                    sum += k
                    if sum > amount
                        sum -= k
                        break
                    elsif sum == amount
                        result_banknotes[k] += 1
                        @banknotes.each_key {|k| @banknotes[k] -= result_banknotes[k]}
                        @currAccount["balance"] -= amount
                        puts "\nYour New Balance is ₴#{@currAccount["balance"]}\n\n"
                        return true
                    else
                        result_banknotes[k] += 1
                        next
                    end
                end
            end
            tmp_banknotes.shift
        end
        puts "\nERROR: THE AMOUNT YOU REQUESTED CANNOT BE COMPOSED FROM BILLS AVAILABLE IN THIS ATM. PLEASE ENTER A DIFFERENT AMOUNT:"
        print "> "
        return false
    end

    def atmCashAmount
        amnt = 0
        @banknotes.each do |k, v|
            amnt += k * v
        end
        return amnt
    end
    
end

ivanBank = ATM.new('config.yml')
ivanBank.authentificate