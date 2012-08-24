
<% @databases.each do |type,db| %>
  <% db.each do |variable,value| %>
BUILD_DATABASE_<%= type.upcase %>_<%= variable.upcase %>=<%= value %>
  <% end %>

  <% db.each do |variable,value| %>
export BUILD_DATABASE_<%= type.upcase %>_<%= variable.upcase %>
  <% end %>
<% end %>