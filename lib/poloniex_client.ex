defmodule PoloniexClient do
  @moduledoc """
  Documentation for PoloniexClient.
  """

  @doc """
  Hello world.

  ## Examples

      iex> PoloniexClient.hello
      :world

  """
  def hello do
    :world
  end
end

defmodule PoloniexClient.Public do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://poloniex.com/public"
  plug Tesla.Middleware.JSON

  adapter Tesla.Adapter.Hackney

  def ticker() do
    get("", query: [command: "returnTicker"]).body
  end

  def volume_24h() do
    get("", query: [command: "return24Volume"]).body
  end

  def order_book(market \\ "all", depth \\ 10) do # market format: BTC_ETH
    get("", query: [command: "returnOrderBook", currencyPair: market, depth: depth]).body
  end

  def trade_history(market) do
    get("", query: [command: "returnTradeHistory", currencyPair: market]).body
  end

  # TODO: add start/end for trade history
  # TODO: returnChartData, returnLoanOrders

  def currencies() do
    get("", query: [command: "returnCurrencies"]).body
  end
end

defmodule PoloniexClient.Trading do
  use Tesla

  # plug Tesla.Middleware.DebugLogger

  adapter Tesla.Adapter.Hackney

  defp trading_client(command, params \\ %{}) do
    query_data = Map.merge(%{"command" => command, "nonce" => System.system_time(:microsecond)}, params) |> URI.encode_query
    query_headers = %{
      "Key" => System.get_env("POLONIEX_API_KEY"),
      "Sign" => Base.encode16(:crypto.hmac(:sha512, System.get_env("POLONIEX_API_SECRET"), query_data)),
      "Content-Type" => "application/x-www-form-urlencoded"
    }
    post("https://poloniex.com/tradingApi", query_data, headers: query_headers).body |> Poison.decode!
  end

  def balances() do
    trading_client("returnBalances")
  end

  def complete_balances() do
    trading_client("returnCompleteBalances")
  end

  def deposit_addresses() do
    trading_client("returnDepositAddresses")
  end

  # TODO: generateNewAddress
  # TODO: returnDepositsWithdrawals

  def open_orders(currency_pair \\ "all") do # currency_pair format: BTC_ETH
    trading_client("returnOpenOrders", %{"currencyPair" => currency_pair})
  end

  def trade_history(currency_pair \\ "all") do # TODO: add START and END date in UNIX timestamp
    trading_client("returnTradeHistory", %{"currencyPair" => currency_pair})
  end

  def order_trades(order_number) do # TODO: add START and END date in UNIX timestamp
    trading_client("returnOrderTrades", %{"orderNumber" => order_number})
  end

 # TODO: buy, sell

 def cancel_order(order_number) do
   trading_client("cancelOrder", %{"orderNumber" => order_number})
 end

 # TODO: moveOrder
 # TODO: withdraw
 #
  def fee_info() do
    trading_client("returnFeeInfo")
  end

  def available_account_balances() do
    trading_client("returnAvailableAccountBalances")
  end

  def available_account_balances(account) do
    trading_client("returnAvailableAccountBalances", %{"account" => account})
  end

  def tradable_balances() do
    trading_client("returnTradableBalances")
  end

  # TODO: transferBalance

  def margin_account_summary do
    trading_client("returnMarginAccountSummary")
  end

  # TODO: marginBuy, marginSell
  # TODO: getMarginPosition, closeMarginPosition

  # TODO: createLoanOffer, cancelLoanOffer, returnOpenLoanOffers, returnActiveLoans, returnLendingHistory, toggleAutoRenew
end
