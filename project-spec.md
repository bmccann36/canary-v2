================================================================
CANARY DEMO MVP - TECHNICAL REQUIREMENTS
================================================================

GOAL
----
Build a minimal demo app to prove out canary deployment architecture:

- Edge-based routing to serve either "stable" or "next" frontend builds
- Org-based (a.k.a tenant-based) routing decision stored in a cookie
- Integrated login page in both builds

================================================================
FEATURES & REQUIREMENTS
================================================================

1. TWO FRONTEND BUILDS
----------------------

✅ Stable frontend build
- Route served: /stable/
- Displays a visible banner:
"STABLE BUILD"

✅ Next frontend build
- Route served: /next/
- Displays a visible banner:
"NEXT BUILD"

Both:
- Contain an identical login page
- Contain a simple "home" page after login

================================================================

2. LOGIN PAGE
-------------

✅ Present in both stable and next builds. Use AWS amplify sdk for simplicity.

Login page:
- Username + password fields 
- On login success:

        - Sets cookie:
            orgId=ORG_ABC; etc....
        - Redirects user to /home page in the same build or other build version
        - Probably have to force a refresh so that user gets next version if applicable

- Login has to happen because we need to read user attributes to determine orgId and set cookie.

================================================================

3. EDGE ROUTING LOGIC
----------------------------------

CloudFront Function

Logic:
- Reads orgId cookie from request
- Looks up if org is in "next rollout" list
- Routes:
- /next/ build → if org in rollout
- /stable/ build → otherwise

Rollout control:
- For now can be a static file like csv or txt or whatever makes sense that gets packaged with the CF function. Idea is later this would read from a config service or database.

================================================================

4. ORG-BASED ROUTING
--------------------

✅ Routing decisions based on orgId cookie

- Default behavior:
    - If no orgId cookie → serve stable build
- Once user logs in:
    - Cookie persists
    - Org-based routing applies on next requests
    - This way we can control which orgs see the next build and change that dynamically over the course of a day/week

================================================================

7. DEMO FLOW
------------

a) User lands on app → no cookie → default to stable build
b) Logs in via stable build login page
→ cookie orgId=ORG_ABC is set
c) Edge routing middleware routes future requests:
- If ORG_ABC is in rollout list → serve next build
- Else → stay on stable
d) Update rollout config to add ORG_ABC
e) Refresh page → user routed to next build

================================================================

TECH STACK PREFERENCES
----------------------

Frontend:
- React
- AWS Cognito, Amplify sdk if simpler

Backend:
- AWS
- CloudFront  
- AWS SAM
