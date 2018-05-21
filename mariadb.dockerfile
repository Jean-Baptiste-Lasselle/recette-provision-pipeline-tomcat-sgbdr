FROM mariadb:10.1
ADD ./my.cnf .
RUN cp /my.cnf /etc/mysql/my.cnf
ADD ./creer-bdd-application.sql .
ADD ./creer-bdd-application.sh .
ADD ./creer-utilisateur-applicatif.sql .
ADD ./creer-utilisateur-applicatif.sh .
ADD ./configurer-utilisateur-mgmt.sql .
ADD ./configurer-utilisateur-mgmt.sh .
RUN chmod +x ./creer-bdd-application.sh
RUN chmod +x ./creer-utilisateur-applicatif.sh
RUN chmod +x ./configurer-utilisateur-mgmt.sh

EXPOSE 3306
CMD ["mysqld"]