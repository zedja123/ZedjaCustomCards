--Build Rider - Misora
local s,id,o=GetID()
function s.initial_effect(c)
	-- Special Summon from hand if only control "Build Rider" monsters
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetCountLimit(1, {id, 1})
	c:RegisterEffect(e1)

	-- Banish this card from GY and banish opponent's card to Special Summon banished "Build Rider"
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1, {id, 2})
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		and not Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.spfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0xf15)
end

-- Cost function: Target a banished "Build Rider" monster and an opponent's card, then banish this card
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- Check if we can select both a valid banished "Build Rider" monster and an opponent's card in the Graveyard
		return Duel.IsExistingMatchingCard(s.filter_banished, tp, LOCATION_REMOVED, 0, 1, nil)
			and Duel.IsExistingMatchingCard(s.filter_grave, tp, 0, LOCATION_GRAVE, 1, nil)
	end
	-- Select the targets for the cost
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
	local g1=Duel.SelectMatchingCard(tp, s.filter_banished, tp, LOCATION_REMOVED, 0, 1, 1, nil)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
	local g2=Duel.SelectMatchingCard(tp, s.filter_grave, tp, 0, LOCATION_GRAVE, 1, 1, nil)
	local tc1=g1:GetFirst()
	local tc2=g2:GetFirst()
	if tc1 and tc2 then
		-- Set the targets for the operation
		e:SetLabelObject(tc1)
		e:SetLabelObject(tc2)
		-- Banish this card as cost
		Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_COST)
	end
end

-- Target function: Update the operation info
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject() end
	local tc1=e:GetLabelObject()
	local tc2=e:GetLabelObject()
	if tc1 and tc2 then
		Duel.SetOperationInfo(0, CATEGORY_REMOVE, tc2, 1, 0, 0)
		Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, tc1, 1, 0, 0)
	end
end

-- Filter function for banished "Build Rider" monsters
function s.filter_banished(c)
	return c:IsSetCard(0xf15) and c:IsFaceup() and c:IsAbleToRemove()
end

-- Filter function for opponent's cards in the Graveyard
function s.filter_grave(c)
	return c:IsAbleToRemove()
end

-- Operation function: Remove the opponent's card and special summon the targeted "Build Rider" monster with effects negated
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc1=e:GetLabelObject()  -- The banished "Build Rider" monster
	local tc2=e:GetLabelObject()  -- The opponent's card in the Graveyard
	if tc1 and tc2 then
		-- Banish the opponent's card
		Duel.Remove(tc2, POS_FACEUP, REASON_EFFECT)
		-- Special summon the "Build Rider" monster
		Duel.SpecialSummon(tc1, 0, tp, tp, false, false, POS_FACEUP)
		-- Negate its effects
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD)
		tc1:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT + RESETS_STANDARD)
		tc1:RegisterEffect(e2)
	end
end