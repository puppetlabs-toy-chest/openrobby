defmodule RobbyWeb.Plugs.LoadEmployeeIds do
  import Plug.Conn
  require Ecto.Query

  def init(opts), do: opts

  def call(conn, _) do
    assign(conn, :all_employee_start_dates, get_list_of_employee_ids())
  end

  def get_list_of_employee_ids do
    ConCache.get(:full_company_employee_ids, :all)
    |> case do
      nil ->
        list =
          Ecto.Query.from(u in RobbyWeb.Directory.orgPeople,
            select: u.startDate)
          |> RobbyWeb.LdapRepo.all
          |> Enum.sort
        ConCache.put(:full_company_employee_ids, :all, list)
        list
      list -> list
    end
  end
end
