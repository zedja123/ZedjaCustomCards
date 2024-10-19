-- Milacresy Ancestor - Sanguina
local s,id=GetID()
function s.initial_effect(c)
	-- Link Summon
	Link.AddProcedure(c,s.matfilter,2,99) -- Link 2 or more with "Milacresy" monsters
	c:EnableReviveLimit()

	-- Effect: Banish 3 cards and destroy
	local e1=Effect.CreateEffect(c)
 -- Set description for the effect
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1, {id, 1})
	e1:SetTarget(s.bantg)
	e1:SetOperation(s.banop)
	c:RegisterEffect(e1)

	-- Quick Effect: Negate effect
	local e2=Effect.CreateEffect(c) -- Set description for the quick effect
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1, {id, 2})
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
	-- Check if there are at least 3 cards in your Deck
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 then
		local g=Duel.GetDecktopGroup(tp,3) -- Get the top 3 cards of your Deck
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT) -- Banish them face-up
		
		-- Count how many of the banished cards are "Milacresy" cards
		local ct=g:FilterCount(Card.IsSetCard,nil,0xf16)
		if ct>0 then
			-- Optional destruction effect
			if Duel.IsExistingMatchingCard(Card.IsDestructible,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) 
				and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				-- Select cards to destroy up to the number of "Milacresy" cards banished
				local dg=Duel.SelectMatchingCard(tp,Card.IsDestructible,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
				if #dg>0 then
					Duel.Destroy(dg,REASON_EFFECT)
				end
			end
		end
	end
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and Duel.IsChainNegatable(ev)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.banishfilter,tp,LOCATION_REMOVED,0,4,nil) end
	-- Select and shuffle 4 "Milacresy" cards from your banished zone into the deck
end

function s.banishfilter(c)
	return c:IsSetCard(0xf16) and c:IsAbleToDeck()
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.banishfilter,tp,LOCATION_REMOVED,0,2,2,nil)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST) then
		Duel.Destroy(eg,REASON_EFFECT)
   local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD) -- Field effect
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET) -- Apply to player
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetTargetRange(1,0) -- Target the player controlling "Milacresy" monsters
	e1:SetTarget(function(e,c) return c:IsSetCard(0xf16) and c:IsType(TYPE_MONSTER) end) -- Target "Milacresy" monsters
	e1:SetReset(RESET_CHAIN) -- Reset at the end of the ChainAttack
 -- Prevent returning to hand
	Duel.RegisterEffect(e1,tp) -- Register the effect
	end
end

