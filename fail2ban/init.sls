{% set banaction = salt['pillar.get']('fail2ban:banaction', 'hostsdeny') %}
{% set lsb_distrib_id = salt['grains.get']('lsb_distrib_id', 'Debian') %}
{% set lsb_distrib_codename = salt['grains.get']('lsb_distrib_codename', 'stretch') %}

fail2ban:
  pkg:
    - installed
  service.running:
    - enable: true
    - watch:
      - file: /etc/fail2ban/jail.conf
      - file: /etc/fail2ban/filter.d/sshd.conf
    - pkg: fail2ban

/etc/fail2ban/jail.conf:
  file.managed:
    - source: salt://fail2ban/jail.conf-{{ lsb_distrib_id }}-{{ lsb_distrib_codename }}
    - user: root
    - group: root
    - mode: 444
    - template: jinja
    - context:
      banaction: {{ banaction }}
    - require:
      - pkg: fail2ban

/etc/fail2ban/filter.d/sshd.conf:
  file.managed:
    - source: salt://fail2ban/filter.d/sshd.conf-{{ lsb_distrib_id }}
    - user: root
    - group: root
    - mode: 444
    - require:
      - pkg: fail2ban

{% if banaction == 'hostsdeny' %}
/etc/fail2ban/action.d/hostsdeny.conf:
  file.managed:
    - source: salt://fail2ban/action.d/hostsdeny.conf
    - user: root
    - group: root
    - mode: 444
    - watch_in:
      - service: fail2ban
    - require:
      - pkg: fail2ban
{% endif %}

{% if banaction == 'shorewall' %}
/etc/fail2ban/action.d/shorewall.conf:
  file.managed:
    - source: salt://fail2ban/action.d/shorewall.conf
    - user: root
    - group: root
    - mode: 444
    - watch_in:
      - service: fail2ban
    - require:
      - pkg: fail2ban
{% endif %}
