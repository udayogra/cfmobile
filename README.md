Let’s build a simple mobile application which will extensively use the server side tags and functionalities.
This will be a dummy bank application in which we can add transactions, list all the saved transactions, generate PDF report of all transactions, convert them into a spreadsheet and sent the reports as part of an email.
All this looks highly impossible in plain Javascript code but with ColdFusion we can implement all these functionalities in much quicker and simplified manner.

Adding a Transaction
Lets first write a plain HTML which will take two input elements for transaction amount and the name of the person to whom you need to transfer. Also a submit button which will add this transaction.
HTML
<html >
   <body>
      <h1>Adobe Bank</h1>
      
      <h2>Add Transaction</h2>
      <form >
         <table >
            <tr>
               <td>Name:</td>
               <td><input type="text" id="name"></td>
            </tr>
            <tr>
               <td>Amount:</td>
               <td><input type="number" id="amtTxt"></td>
            </tr>
            <tr>
               <td colspan="2">
                  <button type="button" id="addBtn">Add</button>
               </td>
            </tr>
         </table>
      </form>
      
   </body>
</html>

 

Now lets add the javascript code which will act when submit button is clicked

Javascript
<script >
   document.getElementById("addBtn").onclick = function(){
      addTransaction();
   }
</script>

Now lets see the coldfusion code written inside the addTransaction method
P.S : We are using tag syntax so that all developers can understand this article. We recommend you all to use cfscript syntax 

ColdFusion

<cffunction name="addTransaction" >
      <cfset var amt = Number(document.getElementById("amtTxt").value)>
      <cfset var desc = document.getElementById("name").value>
      <!--- Insert expense row into database table --->   
      <cfquery type='server' datasource="MYSQL2" result="result">
         insert into bank (fromuser,name,amount) values ("uday",
         <cfqueryparam value="#desc#" maxlength="17">
         ,
         <cfqueryparam value="#amt#" maxlength="17">
         )
      </cfquery>
      <cfset alert('Transaction has been added. Generated key : ' & #result.GENERATEDKEY#)>;
   </cffunction>

Here first we use <Cfset> tag to assign ‘amt’ variable the amount value entered in the HTML input box. You can see how we have mixed Javascript and ColdFusion code here. Next we assign the value of name HTML input to CF variable. After that we execute the CFQUERY tag. Here we have kept ‘from’ as fixed (‘uday’). IN normal flow you will login the use and the value of from will be the user who has just logged in. We have kept ‘type’ as ‘server’ which means this code needs to be executed at the server specified as ‘mobileserver’ using cfclinetsettings tag like this :
<cfclientsettings  mobileserver='http://localhost:8500' enabledeviceapi="false">

So this cfquery code will basically add this transaction detail in the BANK table present in the database MYSQL2 at the server localhost:8080.

Fetch All Transactions
Now that we can add transactions, lets fetch all the transactions which have been saved so far. First we need to add the HTML for this section :
HTML :
<h2>Transactions:</h2>
      <table id="expList">
         <tr>
            <th>From</th>
            <th>To</th>
            <th>Transaction</th>
         </tr>
      </table>
<button type="button" id="getTransactions">Get transactions</button>
Now we need to add javascript code which will act once the above button is pressed

Javascript :
<script>
 document.getElementById("getTransactions").onclick = function(){
      getTransactions();
   }
</script>

Now lets see the coldfusion(plus JS) code which will fetch these transactions :

ColdFusion:
<cffunction name="getTransactions" >
<cftry>
         <!--- Insert expense row into database table --->   
         <cfquery type='server' datasource="MYSQL2" result="result" name="n2">
            select * from bank;
         </cfquery>
         <cfloop query = "n2"> 
            <cfset addTransactionToDiv(#FROMUSER#,#NAME#,#AMOUNT#)>
         </cfloop>
         <!---<cfloop array='#n.DATA#' index='idx'>
            <cfset addTransactionToDiv(#idx[1]#,#idx[2]#,#idx[3]#)>
            </cfloop>--->
         <cfcatch type="any" name="e">
            <cfset alert(e.message)>
         </cfcatch>
      </cftry>
      <!--- add the new expense row to HTML table --->
   </cffunction>

Here is addTransactionToDiv method which adds each transaction row to HTML table
<cffunction name="addTransactionToDiv" >
      <cfargument name="fromuser" >
      <cfargument name="touser" >
      <cfargument name="amt" >
      <cfoutput >
         <cfsavecontent variable="rowHtml" >
            <tr>
               <td>#fromuser#</td>
               <td>#touser#</td>
               <td>#amt#</td>
            </tr>
         </cfsavecontent>
      </cfoutput>
      <cfset document.getElementById("expList").innerHTML += rowHtml>
   </cffunction>

 

Generating PDF Report
Now lets generate a PDF report for all the transactions which have been saved so far
HTML :
<h2>PDF Report</h2>
      <button type="button" id="getPdfReport">Get PDF Report</button>
      <span id='pdf' name='pdf'></span><br>
      <hr>

Javascript :
<script>
 document.getElementById("getPdfReport").onclick = function(){
      getPdfReport();
   }
</script>


ColdFusion:
<cffunction name="getPdfReport" >
      <cfquery type='server' datasource="MYSQL2" result="result" name="n">
         select * from bank;
      </cfquery>
      <cfset html = '<b style="font-size:40px">Your bank statement</b><br><Br>'>
      <cfloop query = "n"> 
         <cfset html+= '<b style="color:red">' & #FROMUSER# &  '</b>-' & '<i>' & #NAME# & '</i>' & ' <B>' & #AMOUNT# & '</B><br><Br>'>   
      </cfloop>
      <cfhtmltopdf destination='C:\Depot\cf_main\cfusion\wwwroot\report.pdf' overwrite=true>
         <cfoutput>#html#</cfoutput>
      </cfhtmltopdf>
      <cfset document.getElementById("pdf").innerHTML += "Click here to view : <a target='_blank' href='http://localhost:8500report.pdf'>Click</a>">
   </cffunction>

Generating Spreadsheet Report
Now lets generate a PDF report for all the transactions which have been saved so far
HTML :
<h2>Spreadsheet Report</h2>
      <button type="button" id="ssbtn">Get Spreadsheet Report</button>
      <span id='ss' name='ss'></span><br>
      <hr>

 

Javascript :
<script>
document.getElementById("ssbtn").onclick = function(){
      getSpreadSheetReport();
   }   }
</script>


ColdFusion:
<cffunction name="getSpreadSheetReport" >
      <cfquery
         name="centers" datasource="MYSQL2"     type="server"> 
         SELECT * FROM bank 
      </cfquery>
      <cfscript> 
         //Use an absolute path for the files. ---> 
         theFile="C:\Depot\cf_main\cfusion\wwwroot\ff\ff.xls"; 
         thesecondsheet = SpreadsheetNew(); 
      </cfscript>
      
      <cfset SpreadsheetAddRows(thesecondsheet,centers)>
      <cfspreadsheet action="write" filename="#theFile#" name="thesecondsheet"
         sheetname="centers" overwrite=true>
      <cfset document.getElementById("ss").innerHTML += "Click here to download : <a target='_blank' href='http://localhost:8500/ff/ff.xls'>Click</a>">
   </cffunction>   

Sending report as an Email
Now lets send these generated reports as an email attachment
HTML :
<h2>Mail reports</h2>
      Mail to :<input type="email" id="email">
      <button type="button" id="mailbtn">Mail</button>
      <span id='mail' name='mail'></span><br>
      <hr>
 

Javascript :
<script>
document.getElementById("mailbtn").onclick = function(){
      mail();
   }
   </script>


ColdFusion:
<cffunction name="mail" >
      <cfset var to = document.getElementById("email").value>
      <cfmail to="#to#" from="bob@work.com"
         subject="Sending a mail with the encryption algo 
         This message is encrypted using the algorithm" >
         <cfmailparam name = "Importance" value = "High">
         Please review the new logo. Tell us what you think. 
         <cfmailparam name="Disposition-Notification-To" value="peter@domain.com">
        <cfmailparam file = "http://localhost:8500/report.pdf" type="text/plain">
      </cfmail>
      <cfset document.getElementById("mail").innerHTML += "Check logs">
   </cffunction>

This pretty much brings us to the end of this sample app. This app would have given you an idea of how we can leverage server side functionalities while building Mobile apps in coldfusion. We need not to write separate front end, separate back end and then integrate both the ends with the help of API calls. You just need to write your front as well as server side logic in the same file. Coldfusion will take care of separating the layers and invoking API calls on your behalf and getting server side code executed at the coldfusion server which you would have specified.
