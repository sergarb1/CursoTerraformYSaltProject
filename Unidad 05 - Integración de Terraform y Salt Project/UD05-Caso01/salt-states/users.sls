# ===========================================
# 📄 salt-states/users.sls
# ===========================================

# 1️⃣ Crear el grupo y el usuario
alumno-user:
  user.present:
    - name: alumno
    - fullname: "Usuario Alumno"
    - shell: /bin/bash
    - home: /home/alumno
    - createhome: True
    - groups:
      - sudo

# 2️⃣ Asignar contraseña usando chpasswd
set-password-alumno:
  cmd.run:
    - name: "echo 'alumno:Alumno123!' | chpasswd"
    - unless: "grep -q '^alumno:' /etc/shadow && getent shadow alumno | cut -d: -f2 | grep -qv '!'"
    - require:
      - user: alumno-user
