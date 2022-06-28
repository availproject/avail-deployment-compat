#!/bin/sh

echo Devnet Information:
echo

{% for item in hostvars %}
echo "- Inventory Hostname: {{ item }}"
echo "  - Node Hostname: {{ hostvars[item].tags.Name }}.{{ lb_dns }}"
echo "  - Role: {{ hostvars[item].tags.Role }}"
echo "  - IP Address: {{ hostvars[item].private_ip_address }}"
{% if (hostvars[item].tags.Role == "validator" or hostvars[item].tags.Role == "full-node" and item != inventory_hostname) %}
echo "  - Maddr: /dns/{{ lb_dns }}/tcp/{{ hostvars[item].tags.AvailPort }}/p2p/{{ lookup('op', 'Wallet Credentials for ' + hostvars[item].tags.Name, vault='Avail Devnet: ' + lineage, field='libP2PPub') | trim }}"
{% endif %}
{% endfor %}

echo
echo
echo "This node was provisioned: {{ ansible_date_time.iso8601 }}"
echo
echo
