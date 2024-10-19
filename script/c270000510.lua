-- Milacresy Ancestor - Sanguina
local s,id=GetID()
function s.initial_effect(c)
	-- Link Summon
	Link.AddProcedure(c,s.matfilter,2,99) -- Link 2 or more with "Milacresy" monsters
	c:EnableReviveLimit()

	-- Effect: Banish 3 cards and destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0)) -- Set description for the effect
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.bantg)
	e1:SetOperation(s.banop)
	c:RegisterEffect(e1)

	-- Quick Effect: Negate effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1)) -- Set description for the quick effect
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end

function s.matfilter(c)
	return c:IsSetCard(0xf16) -- Filter for "Milacresy" monsters
end

function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_DECK,0,3,nil) end
end

function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsExistingMatchingCard(nil,tp,LOCATION_DECK,0,3,nil) then
		local g=Duel.GetDecktopGroup(tp,3)
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		local ct=g:FilterCount(Card.IsSetCard,nil,0xf16) -- Count "Milacresy" cards
		if ct>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=Duel.SelectMatchingCard(tp,Card.IsDestructible,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
			if #dg>0 then
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	end
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and Duel.IsChainNegatable(ev) -- Check if it's your opponent's chain
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.banishfilter,tp,LOCATION_REMOVED,0,4,nil) end
end

function s.banishfilter(c)
	return c:IsSetCard(0xf16) -- Filter for "Milacresy" cards in the banished zone
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,re,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.ShuffleIntoDeck(4,nil,tp) then
		Duel.NegateEffect(ev)
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
end
